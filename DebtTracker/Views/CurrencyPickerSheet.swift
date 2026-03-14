//
//  CurrencyPickerSheet.swift
//  Dime
//

import SwiftUI

struct CurrencyPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: Currency
    @State private var searchText = ""

    private var filteredPopular: [Currency] {
        guard !searchText.isEmpty else { return popularCurrencies }
        return popularCurrencies.filter { matches($0) }
    }

    private var filteredAll: [Currency] {
        let others = allCurrencies.filter { c in
            !popularCurrencies.contains(where: { $0.code == c.code })
        }
        guard !searchText.isEmpty else { return others }
        return others.filter { matches($0) }
    }

    private func matches(_ c: Currency) -> Bool {
        let q = searchText.lowercased()
        return c.name.lowercased().contains(q)
            || c.code.lowercased().contains(q)
            || c.symbol.lowercased().contains(q)
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredPopular.isEmpty {
                    Section("Popular") {
                        ForEach(filteredPopular) { currency in
                            currencyRow(currency)
                        }
                    }
                }
                if !filteredAll.isEmpty {
                    Section("All currencies") {
                        ForEach(filteredAll) { currency in
                            currencyRow(currency)
                        }
                    }
                }
                if filteredPopular.isEmpty && filteredAll.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Search currency")
            .navigationTitle("Select currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func currencyRow(_ currency: Currency) -> some View {
        let isSelected = selectedCurrency.code == currency.code
        Button {
            selectedCurrency = currency
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Text(currency.flag)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.name)
                        .font(.subheadline.weight(.medium))
                    Text(currency.code)
                        .font(.caption)
                }
                Spacer()
                Text(currency.symbol)
                    .font(.subheadline.weight(.semibold))
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .listRowBackground(isSelected ? Color.accentColor : Color.clear)
    }
}
