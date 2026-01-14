import SwiftUI
import SwiftData

// MARK: - Currency Selection View
struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let selectedCurrencyCode: String?
    let onSelect: (Currency) -> Void
    
    @State private var selectedType: CurrencyType = .fiat
    @State private var searchText = ""
    
    private var filteredCurrencies: [Currency] {
        let currencies = CurrencyDataProvider.searchCurrencies(query: searchText, type: selectedType)
        return currencies
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredCurrencies.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredCurrencies, id: \.code) { currency in
                        CurrencyRowView(
                            currency: currency,
                            isSelected: selectedCurrencyCode == currency.code
                        ) {
                            onSelect(currency)
                            dismiss()
                        }
                    }
                }
            }
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
                Image(CurrencyService.getCurrencyIcon(for: currency))
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
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
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Image("check")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
