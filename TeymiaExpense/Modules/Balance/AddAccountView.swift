import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    
    // MARK: - Edit Mode Support
    private let editingAccount: Account?
    private var isEditMode: Bool { editingAccount != nil }
    
    @State private var accountName: String = ""
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedIcon: String = "cash"
    @State private var selectedColor: IconColor = .color1
    @State private var selectedHexColor: String? = nil
    
    @FocusState private var isAccountNameFocused: Bool
    @FocusState private var isInitialBalanceFocused: Bool
    
    // MARK: - Initializers
    init(editingAccount: Account? = nil) {
        self.editingAccount = editingAccount
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Card Preview Section
                Section {
                    AccountIconPreviewView(iconName: selectedIcon, color: previewColor)
                }
                .listRowBackground(Color.clear)
                
                // Account Details
                Section {
                    HStack {
                        TextField("account_name".localized, text: $accountName)
                            .autocorrectionDisabled()
                            .focused($isAccountNameFocused)
                            .submitLabel(.next)
                            .onSubmit {
                                isAccountNameFocused = false
                                isInitialBalanceFocused = true
                            }
                            .fontDesign(.rounded)

                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                accountName = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.secondary.opacity(0.5))
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.plain)
                        .opacity(accountName.isEmpty ? 0 : 1)
                        .scaleEffect(accountName.isEmpty ? 0.001 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: accountName.isEmpty)
                        .disabled(accountName.isEmpty)
                    }
                    .contentShape(Rectangle())
                    
                    HStack {
                        TextField(isEditMode ? "current_balance".localized : "initial_balance".localized, text: $initialBalance)
                            .keyboardType(.decimalPad)
                            .focused($isInitialBalanceFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                isInitialBalanceFocused = false
                            }
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        CurrencySelectionView(selectedCurrencyCode: selectedCurrency?.code) { currency in
                            self.selectedCurrency = currency
                        }
                    } label: {
                        HStack {
                            Image(selectedCurrency != nil ? CurrencyService.getCurrencyIcon(for: selectedCurrency!) : "questionmark.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("currency".localized)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(selectedCurrency?.code ?? "Select")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    ColorSelectionView(selectedColor: $selectedColor, hexColor: $selectedHexColor)
                }
                
                AccountIconSection(selectedIcon: $selectedIcon)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(isEditMode ? "edit_account" : "add_account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()

                ConfirmationToolbarButton(
                    action: {
                        isEditMode ? updateAccount() : saveAccount()
                    },
                    isDisabled: !canSave
                )
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isAccountNameFocused = false
                        isInitialBalanceFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
        .onAppear {
            setupInitialValues()
            if !isEditMode {
                DispatchQueue.main.async {
                    isAccountNameFocused = true
                }
            }
        }
    }
    
    private var previewColor: Color {
        if let hex = selectedHexColor {
            return Color(hex: hex)
        }
        return selectedColor.color
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCurrency != nil
    }
    
    // MARK: - Setup Methods
    private func setupInitialValues() {
        if let account = editingAccount {
            setupEditMode(with: account)
        } else {
            setupCreateMode()
        }
    }
    
    private func setupEditMode(with account: Account) {
        accountName = account.name
        initialBalance = String(describing: account.balance)
        selectedCurrency = account.currency
        selectedIcon = account.customIcon
        selectedColor = account.iconColor
        selectedHexColor = account.hexColor
    }
    
    private func setupCreateMode() {
        if selectedCurrency == nil {
            let userCode = CurrencyService.detectUserCurrency()
            selectedCurrency = CurrencyDataProvider.findCurrency(by: userCode)
        }
    }
    
    // MARK: - Save Account
    private func saveAccount() {
        guard let currency = selectedCurrency else { return }
        
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBalance = initialBalance.replacingOccurrences(of: ",", with: ".")
        let balance = Decimal(string: cleanedBalance) ?? 0
        let account = Account(
            name: trimmedName,
            balance: balance,
            currencyCode: currency.code,
            customIcon: selectedIcon,
            iconColor: selectedColor,
            hexColor: selectedHexColor,
            sortOrder: accounts.count
        )
        
        modelContext.insert(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }

    // MARK: - Update Account
    private func updateAccount() {
        guard let account = editingAccount,
              let currency = selectedCurrency else { return }
        
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedBalance = initialBalance.replacingOccurrences(of: ",", with: ".")
        let newBalance = Decimal(string: cleanedBalance) ?? 0
                
        // Update account properties
        account.name = trimmedName
        account.balance = newBalance
        account.currencyCode = currency.code
        account.customIcon = selectedIcon
        account.iconColor = selectedColor
        account.hexColor = selectedHexColor
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error updating account: \(error)")
        }
    }
}
