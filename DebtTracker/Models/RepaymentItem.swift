//
//  RepaymentItem.swift
//  Dime
//

import Foundation

struct Installment: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let amount: Double

    init(id: UUID = UUID(), date: Date = Date(), amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

// MARK: - RepaymentItem

struct RepaymentItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var currencyCode: String
    var lenderName: String
    var status: Status
    var installments: [Installment]
    var createdAt: Date
    var repaymentDate: Date?
    var reminderHour: Int?
    var reminderMinute: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, amount, currencyCode, lenderName, status, installments, createdAt
        case repaymentDate, reminderHour, reminderMinute
    }

    var currency: Currency {
        allCurrencies.first { $0.code == currencyCode }
            ?? Currency(code: currencyCode, symbol: currencyCode, flag: "🌐", name: currencyCode)
    }

    func formatAmount(_ value: Double) -> String {
        currency.format(value)
    }

    enum Status: String, Hashable, Codable, CaseIterable {
        case inProcess
        case paid
    }

    var repaidAmount: Double {
        installments.reduce(0) { $0 + $1.amount }
    }

    var remainingAmount: Double {
        max(0, amount - repaidAmount)
    }

    var isFullyRepaid: Bool {
        repaidAmount >= amount
    }

    /// 0...100
    var percentPaid: Double {
        guard amount > 0 else { return 0 }
        return min(100, (repaidAmount / amount) * 100)
    }

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        currencyCode: String = "INR",
        lenderName: String,
        status: Status = .inProcess,
        installments: [Installment] = [],
        createdAt: Date = Date(),
        repaymentDate: Date? = nil,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.lenderName = lenderName
        self.status = status
        self.installments = installments
        self.createdAt = createdAt
        self.repaymentDate = repaymentDate
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: RepaymentItem, rhs: RepaymentItem) -> Bool { lhs.id == rhs.id }
}
