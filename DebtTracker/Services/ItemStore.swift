//
//  ItemStore.swift
//  Dime
//

import Foundation
import UserNotifications

private let storeFileName = "debt_tracker_items.json"

@Observable
final class ItemStore {
    var items: [RepaymentItem] = [] {
        didSet { save() }
    }

    init() {
        load()
    }

    private var storeURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(storeFileName)
    }

    func load() {
        guard FileManager.default.fileExists(atPath: storeURL.path),
              let data = try? Data(contentsOf: storeURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([RepaymentItem].self, from: data) {
            items = decoded
        }
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: storeURL)
    }

    var inProcessItems: [RepaymentItem] {
        items.filter { $0.status == .inProcess }.sorted { $0.createdAt > $1.createdAt }
    }

    var paidItems: [RepaymentItem] {
        items.filter { $0.status == .paid }.sorted { $0.createdAt > $1.createdAt }
    }

    func add(
        title: String,
        amount: Double,
        currencyCode: String,
        lenderName: String,
        repaymentDate: Date? = nil,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil
    ) {
        let item = RepaymentItem(
            title: title,
            amount: amount,
            currencyCode: currencyCode,
            lenderName: lenderName,
            repaymentDate: repaymentDate,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute
        )
        items.append(item)
        if let due = repaymentDate {
            scheduleReminderNotification(
                itemId: item.id,
                title: item.title,
                repaymentDate: due,
                hour: reminderHour ?? 9,
                minute: reminderMinute ?? 0
            )
        }
    }

    func addRepayment(itemId: UUID, amount: Double, date: Date = Date()) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        var copy = items
        let toRepay = min(amount, copy[index].remainingAmount)
        copy[index].installments.append(Installment(date: date, amount: toRepay))
        if copy[index].repaidAmount >= copy[index].amount {
            copy[index].status = .paid
        }
        items = copy
    }

    func markAsPaid(itemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        var copy = items
        let remaining = copy[index].remainingAmount
        if remaining > 0 {
            copy[index].installments.append(Installment(date: Date(), amount: remaining))
        }
        copy[index].status = .paid
        items = copy
        cancelReminderNotification(itemId: itemId)
    }

    func updateInstallment(itemId: UUID, installmentId: UUID, amount: Double, date: Date) {
        guard let itemIndex = items.firstIndex(where: { $0.id == itemId }),
              let instIndex = items[itemIndex].installments.firstIndex(where: { $0.id == installmentId }) else { return }
        var copy = items
        copy[itemIndex].installments[instIndex] = Installment(id: installmentId, date: date, amount: amount)
        if copy[itemIndex].repaidAmount >= copy[itemIndex].amount {
            copy[itemIndex].status = .paid
        }
        items = copy
    }

    func updateItem(id: UUID, title: String, amount: Double, currencyCode: String, lenderName: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        var copy = items
        copy[index].title = title
        copy[index].amount = amount
        copy[index].currencyCode = currencyCode
        copy[index].lenderName = lenderName
        items = copy
    }

    func deleteItem(id: UUID) {
        items.removeAll { $0.id == id }
        cancelReminderNotification(itemId: id)
    }

    func clearAll() {
        items = []
    }

    /// Merges imported items — adds items whose id is not already present.
    func merge(_ imported: [RepaymentItem]) {
        let existingIds = Set(items.map(\.id))
        let newItems = imported.filter { !existingIds.contains($0.id) }
        items.append(contentsOf: newItems)
    }

    func item(byId id: UUID) -> RepaymentItem? {
        items.first { $0.id == id }
    }

    // MARK: - Reminder notifications (one day before repayment day)

    private func reminderNotificationIdentifier(itemId: UUID) -> String {
        "debt_reminder_\(itemId.uuidString)"
    }

    private func scheduleReminderNotification(itemId: UUID, title: String, repaymentDate: Date, hour: Int, minute: Int) {
        let calendar = Calendar.current
        guard let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: repaymentDate) else { return }
        let components = calendar.dateComponents([.year, .month, .day], from: oneDayBefore)
        var triggerComponents = DateComponents()
        triggerComponents.year = components.year
        triggerComponents.month = components.month
        triggerComponents.day = components.day
        triggerComponents.hour = hour
        triggerComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Repayment reminder"
        content.body = "\(title) is due tomorrow. Don’t forget to repay."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: reminderNotificationIdentifier(itemId: itemId), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelReminderNotification(itemId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier(itemId: itemId)])
    }
}
