//
//  CreateItemView.swift
//  Dime
//

import SwiftUI
import UserNotifications

struct CreateItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ItemStore.self) private var store

    @State private var title = ""
    @State private var amountText = ""
    @State private var lenderName = ""
    @State private var selectedCurrency: Currency = allCurrencies.first { $0.code == "INR" } ?? allCurrencies[0]
    @State private var showCurrencyPicker = false
    @State private var showError = false
    @State private var showNotificationDeniedAlert = false

    private static var defaultRepaymentDate: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
    @State private var repaymentDate = CreateItemView.defaultRepaymentDate
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .textContentType(.none)
                } header: {
                    Text("What was paid")
                }

                Section {
                    Button {
                        showCurrencyPicker = true
                    } label: {
                        HStack {
                            Text(selectedCurrency.flag)
                            Text(selectedCurrency.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(selectedCurrency.code) \(selectedCurrency.symbol)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 4) {
                        Text(selectedCurrency.symbol)
                            .foregroundStyle(.secondary)
                        TextField("0", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("Amount")
                }

                Section {
                    TextField("Name", text: $lenderName)
                        .textContentType(.name)
                } header: {
                    Text("Paid by")
                } footer: {
                    Text("Person who paid this amount for you. You will repay them.")
                }

                Section {
                    DatePicker("Repayment day", selection: $repaymentDate, in: Date()..., displayedComponents: .date)
                    DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("You'll get a notification one day before the repayment day at this time.")
                }
            }
            .navigationTitle("New repayment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }
                }
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerSheet(selectedCurrency: $selectedCurrency)
            }
            .alert("Missing fields", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter title, amount, and who paid.")
            }
            .alert("Notifications Off", isPresented: $showNotificationDeniedAlert) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Reminders are disabled. You can enable them in Settings → Debt Tracker → Notifications to get repayment reminders.")
            }
        }
    }

    private func create() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLender = lenderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ""))

        guard !trimmedTitle.isEmpty, !trimmedLender.isEmpty, let amt = amount, amt > 0 else {
            showError = true
            return
        }

        let hour = Calendar.current.component(.hour, from: reminderTime)
        let minute = Calendar.current.component(.minute, from: reminderTime)

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            let dismissAfter = granted
                            addDebtAndDismiss(trimmedTitle: trimmedTitle, amount: amt, trimmedLender: trimmedLender, hour: hour, minute: minute, dismiss: dismissAfter)
                            if !granted { showNotificationDeniedAlert = true }
                        }
                    }
                case .denied:
                    addDebtAndDismiss(trimmedTitle: trimmedTitle, amount: amt, trimmedLender: trimmedLender, hour: hour, minute: minute, dismiss: false)
                    showNotificationDeniedAlert = true
                case .authorized, .provisional, .ephemeral:
                    addDebtAndDismiss(trimmedTitle: trimmedTitle, amount: amt, trimmedLender: trimmedLender, hour: hour, minute: minute, dismiss: true)
                @unknown default:
                    addDebtAndDismiss(trimmedTitle: trimmedTitle, amount: amt, trimmedLender: trimmedLender, hour: hour, minute: minute, dismiss: true)
                }
            }
        }
    }

    private func addDebtAndDismiss(trimmedTitle: String, amount: Double, trimmedLender: String, hour: Int, minute: Int, dismiss: Bool = true) {
        store.add(
            title: trimmedTitle,
            amount: amount,
            currencyCode: selectedCurrency.code,
            lenderName: trimmedLender,
            repaymentDate: repaymentDate,
            reminderHour: hour,
            reminderMinute: minute
        )
        if dismiss { self.dismiss() }
    }
}

#Preview {
    CreateItemView()
        .environment(ItemStore())
}
