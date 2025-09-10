import SwiftUI
import SwiftData

// MARK: - Simple Currency Selection View
struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: Currency?
    
    @State private var selectedType: CurrencyType = .fiat
    @State private var searchText = ""
    
    private var filteredCurrencies: [Currency] {
        let currencies = CurrencyData.searchCurrencies(query: searchText, type: selectedType)
        return currencies
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Currency Type Picker
                currencyTypePicker
                
                // Currency List
                List(filteredCurrencies, id: \.code) { currency in
                    CurrencyRowView(
                        currency: currency,
                        isSelected: selectedCurrency?.code == currency.code
                    ) {
                        selectedCurrency = currency
                        dismiss()
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText)
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Currency Type Picker
    private var currencyTypePicker: some View {
        Picker("Currency Type", selection: $selectedType) {
            Text("Fiat").tag(CurrencyType.fiat)
            Text("Crypto").tag(CurrencyType.crypto)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .onChange(of: selectedType) { oldValue, newValue in
            searchText = "" // Clear search when switching types
        }
    }
}

// MARK: - Currency Row View
struct CurrencyRowView: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Currency flag/icon
                Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.separator, lineWidth: 0.5)
                    )
                
                // Currency info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(currency.code)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(currency.symbol)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accent)
                        .font(.title2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}
