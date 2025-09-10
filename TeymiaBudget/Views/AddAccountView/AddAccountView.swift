import SwiftUI
import SwiftData

// MARK: - Add Account View
struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var currencies: [Currency]
    
    @State private var accountName: String = ""
    @State private var selectedAccountType: AccountType = .cash
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var showingCurrencySelection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Account Name
                    accountNameSection
                    
                    // Account Type
                    accountTypeSection
                    
                    // Currency Selection
                    currencySelectionSection
                    
                    // Initial Balance
                    initialBalanceSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {                
                ToolbarItem(placement: .primaryAction) {
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
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView(selectedCurrency: $selectedCurrency)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.accent)
            
            VStack(spacing: 6) {
                Text("New Account")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create a new account to track your money")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Account Name Section
    private var accountNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Name")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Enter account name", text: $accountName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
    }
    
    // MARK: - Account Type Section
    private var accountTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Type")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(AccountType.allCases, id: \.self) { type in
                    accountTypeButton(type: type)
                }
            }
        }
    }
    
    // MARK: - Currency Selection Section
    private var currencySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currency")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button {
                showingCurrencySelection = true
            } label: {
                HStack(spacing: 12) {
                    if let currency = selectedCurrency {
                        Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(currency.code) - \(currency.name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Symbol: \(currency.symbol)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Select Currency")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.separator, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Initial Balance Section
    private var initialBalanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Initial Balance")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text(selectedCurrency?.symbol ?? "$")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $initialBalance)
                    .font(.title2)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    // MARK: - Account Type Button
    private func accountTypeButton(type: AccountType) -> some View {
        Button {
            selectedAccountType = type
        } label: {
            VStack(spacing: 12) {
                Image(systemName: iconForAccountType(type))
                    .font(.largeTitle)
                    .foregroundColor(selectedAccountType == type ? .white : .accent)
                
                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(selectedAccountType == type ? .white : .primary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedAccountType == type ? .accent : .gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.isEmpty && selectedCurrency != nil
    }
    
    // MARK: - Helper Methods
    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bankAccount: return "building.columns"
        case .creditCard: return "creditcard"
        case .savings: return "piggybank"
        }
    }
    
    private func setupDefaults() {
        // Set default currency (USD if available)
        selectedCurrency = currencies.first { $0.isDefault } ?? currencies.first
    }
    
    private func saveAccount() {
        guard let currency = selectedCurrency else { return }
        
        let balance = Decimal(string: initialBalance) ?? 0
        
        let account = Account(
            name: accountName,
            type: selectedAccountType,
            balance: balance,
            currency: currency,
            isDefault: false
        )
        
        modelContext.insert(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Handle error - could show alert
            print("Error saving account: \(error)")
        }
    }
}

// MARK: - AccountType Extension
extension AccountType {
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .bankAccount: return "Bank"
        case .creditCard: return "Credit Card"
        case .savings: return "Savings"
        }
    }
}
