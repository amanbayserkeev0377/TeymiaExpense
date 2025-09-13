import SwiftUI
import SwiftData

struct CurrencySelectionRow: View {
    let selectedCurrency: Currency?
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                if let currency = selectedCurrency {
                    Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    
                    Text("\(currency.code) - \(currency.name)")
                        .foregroundColor(.primary)
                        .lineLimit(1)
                } else {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                    
                    Text("Select Currency")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Currency Selection View
struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
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
                
                // Currency List with grouped style
                List {
                    Section {
                        ForEach(filteredCurrencies, id: \.code) { currency in
                            CurrencyRowView(
                                currency: currency,
                                isSelected: selectedCurrency?.code == currency.code
                            ) {
                                selectedCurrency = currency
                                dismiss()
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText)
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
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
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.separator, lineWidth: 0.5)
                    )
                
                // Currency info
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(currency.code)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text(currency.symbol)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(currency.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image("check")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
