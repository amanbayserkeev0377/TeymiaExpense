import SwiftUI
import SwiftData

struct CurrencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserPreferences.self) private var userPreferences
    @Environment(\.colorScheme) var colorScheme
    @Query private var currencies: [Currency]
    
    @State private var selectedType: CurrencyType = .fiat
    @State private var searchText = ""
    
    private var filteredCurrencies: [Currency] {
        let currencies = CurrencyData.searchCurrencies(query: searchText, type: selectedType)
        return currencies
    }
    
    var body: some View {
        List {
            ForEach(filteredCurrencies, id: \.code) { currency in
                CurrencyRowView(
                    currency: currency, isSelected: userPreferences.baseCurrencyCode == currency.code
                ) {
                    userPreferences.baseCurrencyCode = currency.code
                    dismiss()
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
        .searchable(text: $searchText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $selectedType) {
                    Text("fiat".localized).tag(CurrencyType.fiat)
                    Text("crypto".localized).tag(CurrencyType.crypto)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                .onChange(of: selectedType) { oldValue, newValue in
                    searchText = ""
                }
            }
        }
    }
}


