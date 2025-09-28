import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    
    // MARK: - Edit Mode Support
    private let editingTransaction: Transaction?
    private var isEditMode: Bool { editingTransaction != nil }
    
    // MARK: - Form State
    @State private var selectedType: TransactionType = .expense
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    
    @State private var showingAddAccount = false
    @FocusState private var isAmountFieldFocused: Bool
    
    // MARK: - Initializers
    init(editingTransaction: Transaction? = nil) {
        self.editingTransaction = editingTransaction
    }
    
    var body: some View {
        NavigationStack {
            Form {
                AmountInputSection(
                    amount: $amount,
                    selectedTransactionType: $selectedType,
                    isAmountFieldFocused: $isAmountFieldFocused,
                    currencySymbol: currencySymbol
                )
                
                // Category Section (only for income/expense)
                if selectedType != .transfer {
                    Section {
                        NavigationLink {
                            CategorySelectionView(
                                transactionType: selectedType == .income ? .income : .expense,
                                selectedCategory: selectedCategory,
                                onSelectionChanged: { category in
                                    selectedCategory = category
                                }
                            )
                        } label: {
                            CategorySelectionRow(selectedCategory: selectedCategory)
                        }
                    }
                    .listRowBackground(Color.mainRowBackground)
                }
                
                // Account/Transfer Section
                if selectedType == .transfer {
                    TransferAccountsSection(
                        fromAccount: $fromAccount,
                        toAccount: $toAccount,
                        accounts: accounts,
                        onAddAccountTapped: { showingAddAccount = true }
                    )
                } else {
                    AccountSelectionSection(
                        selectedAccount: $selectedAccount,
                        accounts: accounts
                    )
                }
                
                // Date & Note
                DateNoteSection(date: $date, note: $note)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground.ignoresSafeArea())
            .navigationTitle(isEditMode ? "Edit Transaction" : selectedType.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button { isAmountFieldFocused = false } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        isEditMode ? updateTransaction() : saveTransaction()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear { setupInitialValues() }
        .onChange(of: selectedType) { oldValue, newValue in
            handleTypeChange(from: oldValue, to: newValue)
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Computed Properties
    
    private var currencySymbol: String {
        if selectedType == .transfer {
            return fromAccount?.currency.symbol ?? "$"
        }
        return selectedAccount?.currency.symbol ?? "$"
    }
    
    private var canSave: Bool {
        guard !amount.isEmpty,
              let amountValue = Double(amount),
              amountValue > 0 else { return false }
        
        switch selectedType {
        case .expense, .income:
            return selectedAccount != nil && selectedCategory != nil
        case .transfer:
            return fromAccount != nil && toAccount != nil && fromAccount != toAccount
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupInitialValues() {
        if let transaction = editingTransaction {
            setupForEditing(transaction)
        } else {
            setupForCreating()
        }
        
        // Focus amount field for new transactions
        if !isEditMode {
            DispatchQueue.main.async {
                isAmountFieldFocused = true
            }
        }
    }
    
    private func setupForEditing(_ transaction: Transaction) {
        selectedType = transaction.type
        amount = String(describing: abs(transaction.amount))
        selectedAccount = transaction.account
        selectedCategory = transaction.category
        note = transaction.note ?? ""
        date = transaction.date
        
        if transaction.type == .transfer {
            fromAccount = transaction.account
            toAccount = transaction.toAccount
        }
    }
    
    private func setupForCreating() {
        selectedAccount = userPreferences.getPreferredAccount(from: accounts)
        fromAccount = selectedAccount
        
        if accounts.count > 1 {
            toAccount = accounts.first { $0.id != selectedAccount?.id }
        }
        
        selectedCategory = TransactionService.getDefaultCategory(
            for: selectedType,
            from: categories
        )
    }
    
    private func handleTypeChange(from oldType: TransactionType, to newType: TransactionType) {
        // Update default category when switching types
        if newType != .transfer {
            selectedCategory = TransactionService.getDefaultCategory(
                for: newType,
                from: categories
            )
        }
        
        // Set up transfer accounts if needed
        if newType == .transfer && accounts.count > 1 && toAccount == nil {
            toAccount = accounts.first { $0 != fromAccount }
        }
    }
    
    // MARK: - Save/Update Methods
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        let decimalAmount = Decimal(amountValue)
        
        do {
            switch selectedType {
            case .expense:
                guard let account = selectedAccount, let category = selectedCategory else { return }
                try TransactionService.saveExpense(
                    amount: decimalAmount,
                    account: account,
                    category: category,
                    note: note,
                    date: date,
                    context: modelContext,
                    userPreferences: userPreferences
                )
                
            case .income:
                guard let account = selectedAccount, let category = selectedCategory else { return }
                try TransactionService.saveIncome(
                    amount: decimalAmount,
                    account: account,
                    category: category,
                    note: note,
                    date: date,
                    context: modelContext,
                    userPreferences: userPreferences
                )
                
            case .transfer:
                guard let from = fromAccount, let to = toAccount else { return }
                try TransactionService.saveTransfer(
                    amount: decimalAmount,
                    fromAccount: from,
                    toAccount: to,
                    note: note,
                    date: date,
                    context: modelContext,
                    userPreferences: userPreferences
                )
            }
            
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
            // TODO: Show user-friendly error alert
        }
    }
    
    private func updateTransaction() {
        guard let transaction = editingTransaction,
              let amountValue = Double(amount) else { return }
        
        let decimalAmount = Decimal(amountValue)
        
        do {
            try TransactionService.updateTransaction(
                transaction,
                newAmount: decimalAmount,
                newAccount: selectedType == .transfer ? fromAccount : selectedAccount,
                newToAccount: selectedType == .transfer ? toAccount : nil,
                newCategory: selectedType == .transfer ? nil : selectedCategory,
                newNote: note,
                newDate: date,
                newType: selectedType,
                context: modelContext
            )
            
            dismiss()
        } catch {
            print("Error updating transaction: \(error)")
            // TODO: Show user-friendly error alert
        }
    }
}

// MARK: - TransactionType Extensions
extension TransactionType {
    var displayName: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        case .transfer: return "Transfer"
        }
    }
    
    var darkColor: Color {
        switch self {
        case .expense: return Color(#colorLiteral(red: 0.8, green: 0.1, blue: 0.1, alpha: 1))
        case .income: return Color(#colorLiteral(red: 0.0, green: 0.6431372549, blue: 0.5490196078, alpha: 1))
        case .transfer: return Color(#colorLiteral(red: 0.1490196078, green: 0.4666666667, blue: 0.6784313725, alpha: 1))
        }
    }
    
    var lightColor: Color {
        switch self {
        case .expense: return Color(#colorLiteral(red: 1, green: 0.3, blue: 0.3, alpha: 1))
        case .income: return Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1))
        case .transfer: return Color(#colorLiteral(red: 0.3568627451, green: 0.6588235294, blue: 0.9294117647, alpha: 1))
        }
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [darkColor, lightColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var customIconName: String {
        switch self {
        case .expense: return "expense"
        case .income: return "income"
        case .transfer: return "transfer"
        }
    }
}
