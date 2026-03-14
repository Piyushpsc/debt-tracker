//
//  EditItemView.swift
//  Dime
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ItemStore.self) private var store

    let item: RepaymentItem

    @State private var title: String
    @State private var amountText: String
    @State private var lenderName: String
    @State private var selectedCurrency: Currency
    @State private var showCurrencyPicker = false
    @State private var showError = false

    init(item: RepaymentItem) {
        self.item = item
        _title = State(initialValue: item.title)
        _amountText = State(initialValue: String(Int(item.amount)))
        _lenderName = State(initialValue: item.lenderName)
        _selectedCurrency = State(initialValue: item.currency)
    }

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
                }
            }
            .navigationTitle("Edit item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
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
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLender = lenderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: "")),
              amount > 0,
              !trimmedTitle.isEmpty,
              !trimmedLender.isEmpty else {
            showError = true
            return
        }
        store.updateItem(id: item.id, title: trimmedTitle, amount: amount, currencyCode: selectedCurrency.code, lenderName: trimmedLender)
        dismiss()
    }
}
