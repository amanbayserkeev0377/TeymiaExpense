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
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                    
                    Text("currency".localized)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(currency.code)
                        .foregroundStyle(.secondary)
                    
                } else {
                    Image("dollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                    
                    Text("select_currency".localized)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
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
            List {
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
            .listStyle(.automatic)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Currency Type", selection: $selectedType) {
                        Text("fiat".localized).tag(CurrencyType.fiat)
                        Text("crypto".localized).tag(CurrencyType.crypto)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    .onChange(of: selectedType) { oldValue, newValue in
                        searchText = "" // Clear search when switching types
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .navigationTitle("Select Currency")
        .navigationBarTitleDisplayMode(.large)
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
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
