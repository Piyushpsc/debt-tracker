//
//  ItemDetailView.swift
//  Dime
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()

private let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.timeStyle = .short
    return f
}()

struct ItemDetailView: View {
    @Environment(ItemStore.self) private var store
    let itemId: UUID
    @State private var showRepaySheet = false
    @State private var showEditItem = false
    @State private var showDeleteConfirm = false
    @State private var selectedTab: DetailTab = .details
    @State private var installmentToEdit: Installment?
    @Environment(\.dismiss) private var dismiss

    enum DetailTab: String, CaseIterable, Identifiable {
        case details = "Details"
        case repayment = "Repayment"
        var id: String { rawValue }
    }

    /// Always read from store so edits reflect instantly.
    private var currentItem: RepaymentItem? {
        store.item(byId: itemId)
    }

    var body: some View {
        if let item = currentItem {
            detailContent(item: item)
        } else {
            Color.clear
                .onAppear { dismiss() }
        }
    }

    @ViewBuilder
    private func detailContent(item: RepaymentItem) -> some View {
        VStack(spacing: 0) {
            Picker("Tab", selection: $selectedTab) {
                ForEach(DetailTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGroupedBackground))

            List {
                if selectedTab == .details {
                    Section {
                        LabeledContent("Title", value: item.title)
                        LabeledContent("Amount", value: formatCurrency(item.amount))
                        LabeledContent("Paid by", value: item.lenderName)
                    }

                    Section("Repayment") {
                        LabeledContent("Paid", value: "\(Int(item.percentPaid))%")
                        LabeledContent("Repaid", value: formatCurrency(item.repaidAmount))
                        LabeledContent("Remaining", value: formatCurrency(item.remainingAmount))
                    }

                    if item.status == .inProcess {
                            Section {
                                Button {
                                    store.markAsPaid(itemId: item.id)
                                } label: {
                                    Label("Mark fully paid", systemImage: "checkmark.circle.fill")
                                }

                                Button {
                                    showRepaySheet = true
                                } label: {
                                    Label("Add installment", systemImage: "plus.circle")
                                }
                            }
                        }
                } else {
                    if item.installments.isEmpty {
                            ContentUnavailableView("No repayments yet", systemImage: "clock")
                                .listRowBackground(Color.clear)
                        } else {
                            RepaymentHistoryRows(
                                installments: item.installments.sorted(by: { $0.date > $1.date }),
                                onEdit: { installmentToEdit = $0 },
                                formatDate: formatDate,
                                formatTime: formatTime,
                                formatCurrency: formatCurrency
                            )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.hidden)
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditItem = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditItem) {
            if let item = currentItem {
                EditItemView(item: item)
                    .environment(store)
            }
        }
        .confirmationDialog("Delete this item?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Yes", role: .destructive) {
                store.deleteItem(id: item.id)
                dismiss()
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("This item and all its details will be permanently deleted. Are you sure you want to delete?")
        }
        .sheet(isPresented: $showRepaySheet) {
            AddInstallmentSheetView(
                remainingAmount: item.remainingAmount,
                currencyCode: item.currencyCode,
                onCancel: { showRepaySheet = false },
                onAdd: { amount, date in
                    store.addRepayment(itemId: item.id, amount: amount, date: date)
                    showRepaySheet = false
                }
            )
        }
        .sheet(item: $installmentToEdit) { inst in
            EditInstallmentSheetView(
                installment: inst,
                onCancel: { installmentToEdit = nil },
                onSave: { amount, date in
                    store.updateInstallment(itemId: item.id, installmentId: inst.id, amount: amount, date: date)
                    installmentToEdit = nil
                }
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    private func formatCurrency(_ value: Double) -> String {
        currentItem.formatAmount(value)
    }
}

private struct RepaymentHistoryRows: View {
    let installments: [Installment]
    let onEdit: (Installment) -> Void
    let formatDate: (Date) -> String
    let formatTime: (Date) -> String
    let formatCurrency: (Double) -> String

    var body: some View {
        ForEach(installments, id: \.id) { (inst: Installment) in
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(inst.date))
                            .font(.subheadline.weight(.medium))
                        Text(formatTime(inst.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(formatCurrency(inst.amount))
                        .fontWeight(.semibold)
                    Button {
                        onEdit(inst)
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct EditInstallmentSheetView: View {
    let installment: Installment
    let onCancel: () -> Void
    let onSave: (Double, Date) -> Void
    @State private var amountText: String
    @State private var date: Date

    init(installment: Installment, onCancel: @escaping () -> Void, onSave: @escaping (Double, Date) -> Void) {
        self.installment = installment
        self.onCancel = onCancel
        self.onSave = onSave
        _amountText = State(initialValue: String(Int(installment.amount)))
        _date = State(initialValue: installment.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Amount")
                }

                Section {
                    DatePicker("Date & time", selection: $date)
                        .datePickerStyle(.compact)
                }
            }
            .navigationTitle("Edit repayment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: "")), amount > 0 else { return }
                        onSave(amount, date)
                    }
                }
            }
        }
    }
}

private struct AddInstallmentSheetView: View {
    let remainingAmount: Double
    let currencyCode: String
    let onCancel: () -> Void
    let onAdd: (Double, Date) -> Void
    @State private var amountText = ""
    @State private var date: Date = Date()

    private var currency: Currency {
        allCurrencies.first { $0.code == currencyCode }
            ?? Currency(code: currencyCode, symbol: currencyCode, flag: "🌐", name: currencyCode)
    }

    private var formattedRemaining: String {
        currency.format(remainingAmount)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 4) {
                        Text(currency.symbol)
                            .foregroundStyle(.secondary)
                            .font(.body)
                        TextField("0", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("Amount (\(currency.code))")
                } footer: {
                    Text("Remaining: \(formattedRemaining)")
                }

                Section {
                    DatePicker("Date & time", selection: $date)
                        .datePickerStyle(.compact)
                }
            }
            .navigationTitle("Add installment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: "")), amount > 0 else { return }
                        onAdd(min(amount, remainingAmount), date)
                    }
                }
            }
        }
    }
}

#Preview {
    let store = ItemStore()
    let item = RepaymentItem(
        title: "MBA",
        amount: 315000,
        lenderName: "Shrikant Ajoba",
        installments: [
            Installment(date: Date().addingTimeInterval(-86400 * 30), amount: 50000),
            Installment(date: Date().addingTimeInterval(-86400 * 7), amount: 25000)
        ]
    )
    store.items = [item]
    return NavigationStack { ItemDetailView(itemId: item.id) }
        .environment(store)
}
