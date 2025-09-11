import SwiftUI
import SwiftData

// MARK: - Add Account View
struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var currencies: [Currency]
    
    @State private var accountName: String = ""
    @State private var selectedAccountType: AccountType = .cash
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var showingCurrencySelection = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Account Name Section
                Section("Account Name") {
                    TextField("Enter account name", text: $accountName)
                        .autocorrectionDisabled()
                }
                .listRowBackground(Color.gray.opacity(0.1))
                .listStyle(.plain)
                
                // Account Type Section
                Section("Account Type") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            accountTypeButton(type: type)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                // Currency Section
                Section("Currency") {
                    Button {
                        showingCurrencySelection = true
                    } label: {
                        HStack {
                            if let currency = selectedCurrency {
                                Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 24, height: 24)
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
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, height: 24)
                                
                                Text("Select Currency")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // Initial Balance Section
                Section("Initial Balance") {
                    HStack {
                        Text(selectedCurrency?.symbol ?? "$")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        
                        TextField("0.00", text: $initialBalance)
                            .font(.title3)
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
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
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView(selectedCurrency: $selectedCurrency)
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                .presentationDetents([.fraction(0.99)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
    }
    
    // MARK: - Account Type Button
    private func accountTypeButton(type: AccountType) -> some View {
        Button {
            selectedAccountType = type
        } label: {
            VStack(spacing: 8) {
                Image(iconForAccountType(type))
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedAccountType == type ? .white : .accent)
                
                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedAccountType == type ? .white : .primary)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
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
        case .cash: return "cash"
        case .bankAccount: return "bank"
        case .creditCard: return "credit.card"
        case .savings: return "piggy.bank"
        }
    }
    
    private func setupDefaults() {
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
            print("Error saving account: \(error)")
        }
    }
}
