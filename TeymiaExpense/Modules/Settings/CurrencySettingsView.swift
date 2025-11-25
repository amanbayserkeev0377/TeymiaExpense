import SwiftUI
import SwiftData

struct CurrencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserPreferences.self) private var userPreferences
    
    @State private var selectedType: CurrencyType = .fiat
    @State private var searchText = ""
    
    private var filteredCurrencies: [Currency] {
        CurrencyDataProvider.searchCurrencies(query: searchText, type: selectedType)
    }
    
    var body: some View {
        List {
            Section {
                Picker("Type", selection: $selectedType) {
                    ForEach(CurrencyType.allCases, id: \.self) { type in
                        Text(type == .fiat ? "Fiat" : "Crypto")
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedType) { _, _ in
                    searchText = ""
                }
            }
            .listRowBackground(Color.clear)
            
            // Currency list section
            Section {
                if filteredCurrencies.isEmpty {
                    ContentUnavailableView(
                        "No currencies found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredCurrencies, id: \.code) { currency in
                        CurrencyRowView(currency: currency, isSelected: userPreferences.baseCurrencyCode == currency.code) {
                            userPreferences.baseCurrencyCode = currency.code
                            dismiss()
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .automatic)
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}
