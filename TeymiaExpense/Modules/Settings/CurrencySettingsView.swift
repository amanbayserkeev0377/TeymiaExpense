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
            if filteredCurrencies.isEmpty {
                ContentUnavailableView.search(text: searchText)
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredCurrencies, id: \.code) { currency in
                    CurrencyRowView(currency: currency, isSelected: userPreferences.baseCurrencyCode == currency.code) {
                        userPreferences.baseCurrencyCode = currency.code
                        dismiss()
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.secondary.opacity(0.07))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(BackgroundView())
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $selectedType) {
                    Text("fiat".localized).tag(CurrencyType.fiat)
                    Text("crypto".localized).tag(CurrencyType.crypto)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .onChange(of: selectedType) { oldValue, newValue in
                    searchText = ""
                }
            }
        }
    }
}
