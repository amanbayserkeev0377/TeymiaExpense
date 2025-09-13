import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var currencies: [Currency]
    
    @State private var accountName: String = ""
    @State private var selectedAccountType: AccountType = .cash
    @State private var balance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedColorIndex: Int = 0
    @State private var selectedIcon: String = "cash"
    
    @State private var showingCurrencySelection = false
    @State private var showingIconSelection = false
    
    var selectedColor: Color {
        AccountColors.color(at: selectedColorIndex)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AccountCardPreview(
                        name: accountName,
                        balance: balance,
                        accountType: selectedAccountType,
                        color: selectedColor,
                        icon: selectedIcon,
                        currencyCode: selectedCurrency?.code ?? "USD"
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Account Name
                Section {
                    TextField("account_name".localized, text: $accountName)
                        .autocorrectionDisabled()
                    
                    // Initial Balance
                    HStack {
                        TextField("balance".localized, text: $balance)
                            .keyboardType(.decimalPad)
                        
                        Spacer()
                        
                        Text(selectedCurrency?.symbol ?? "$")
                            .foregroundStyle(.secondary)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.1))
                
                Section {
                    // Color Selection
                    ColorSelectionView(selectedColorIndex: $selectedColorIndex)
                    
                    // Icon Selection
                    IconSelectionRow(
                        selectedIcon: selectedIcon,
                        selectedColor: selectedColor,
                        onTap: { showingIconSelection = true }
                    )
                    
                    // Account Type
                    AccountTypeSelectionRow(
                        selectedAccountType: $selectedAccountType,
                        selectedIcon: $selectedIcon,
                        selectedColor: selectedColor
                    )
                    
                    // Currency
                    CurrencySelectionRow(
                        selectedCurrency: selectedCurrency,
                        onTap: { showingCurrencySelection = true }
                    )
                }
                .listRowBackground(Color.gray.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupDefaults()
        }
        .onChange(of: currencies) { _, newCurrencies in
            if !newCurrencies.isEmpty && selectedCurrency == nil {
                setupDefaults()
            }
        }
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView(selectedCurrency: $selectedCurrency)
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
        .sheet(isPresented: $showingIconSelection) {
            IconSelectionView(selectedIcon: $selectedIcon)
                .presentationDetents([.medium])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.isEmpty && selectedCurrency != nil
    }
    
    // MARK: - Helper Methods
    private func setupDefaults() {
        guard !currencies.isEmpty else { return }
        
        if selectedCurrency == nil {
            selectedCurrency = currencies.first { $0.isDefault } ?? currencies.first
        }
        selectedIcon = iconForAccountType(selectedAccountType)
    }
    
    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "cash"
        case .bankAccount: return "bank"
        case .creditCard: return "credit_card"
        case .savings: return "savings"
        }
    }
    
    private func saveAccount() {
        guard let currency = selectedCurrency else { return }
        
        let balance = Decimal(string: initialBalance) ?? 0
        
        let account = Account(
            name: accountName,
            type: selectedAccountType,
            balance: balance,
            currency: currency,
            isDefault: false,
            customColorHex: selectedColor.toHex(),
            customIcon: selectedIcon
        )
        
        modelContext.insert(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }
}
