//
//  InProcessView.swift
//  Dime
//

import SwiftUI

struct InProcessView: View {
    @Environment(ItemStore.self) private var store
    @State private var searchText = ""
    @State private var showCreateSheet = false
    @State private var selectedCurrencyCode: String? = nil

    private var items: [RepaymentItem] { store.inProcessItems }

    private var currencyChips: [(label: String, code: String?)] {
        let codes = Set(items.map(\.currencyCode)).sorted()
        let allChip = [("All", nil as String?)]
        let currencyChips = codes.map { code -> (String, String?) in
            let currency = allCurrencies.first { $0.code == code }
                ?? Currency(code: code, symbol: code, flag: "🌐", name: code)
            return ("\(currency.symbol) \(currency.code)", code)
        }
        return allChip + currencyChips
    }

    private var filteredItems: [RepaymentItem] {
        var list = items
        if let code = selectedCurrencyCode {
            list = list.filter { $0.currencyCode == code }
        }
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return list }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return list.filter {
            $0.title.lowercased().contains(query) ||
            $0.lenderName.lowercased().contains(query) ||
            "\(Int($0.amount))".contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.inProcessItems.isEmpty {
                    ContentUnavailableView(
                        "No items yet",
                        systemImage: "tray",
                        description: Text("Tap + in the title bar to add something you need to repay.")
                    )
                } else if filteredItems.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if currencyChips.count > 1 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(Array(currencyChips.enumerated()), id: \.offset) { _, chip in
                                            let isSelected = selectedCurrencyCode == chip.code
                                            Button {
                                                selectedCurrencyCode = chip.code
                                            } label: {
                                                Text(chip.label)
                                                    .font(.subheadline.weight(.medium))
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(isSelected
                                                                ? LinearGradient(
                                                                    colors: [Color(red: 0.5, green: 0.35, blue: 1), Color(red: 0.4, green: 0.5, blue: 1)],
                                                                    startPoint: .leading,
                                                                    endPoint: .trailing
                                                                )
                                                                : LinearGradient(colors: [Color(.tertiarySystemFill)], startPoint: .leading, endPoint: .trailing)
                                                            )
                                                    )
                                                    .foregroundStyle(isSelected ? .white : .primary)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.bottom, 4)
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(filteredItems) { item in
                                    NavigationLink(value: item) {
                                        InProcessRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                        .padding(.top, 16)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .searchable(text: $searchText, prompt: "Search by title or lender")
            .navigationTitle("Debt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: RepaymentItem.self) { item in
                ItemDetailView(item: item)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateItemView()
                    .environment(store)
            }
        }
    }
}

private struct InProcessRow: View {
    let item: RepaymentItem

    private func formatAmount(_ value: Double) -> String {
        item.formatAmount(value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(formatAmount(item.amount))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(Int(item.percentPaid))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(item.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.35, blue: 1),
                                    Color(red: 0.4, green: 0.5, blue: 1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * (item.percentPaid / 100), height: 8)
                }
            }
            .frame(height: 8)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatAmount(item.repaidAmount))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatAmount(item.remainingAmount))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .listRowBackground(Color(.systemBackground))
    }
}

#Preview {
    InProcessView()
        .environment(ItemStore())
}
