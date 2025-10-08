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
    private let preselectedAccount: Account?
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
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isAmountFieldFocused: Bool
    
    // MARK: - Initializers
    init(editingTransaction: Transaction? = nil, preselectedAccount: Account? = nil) {
        self.editingTransaction = editingTransaction
        self.preselectedAccount = preselectedAccount
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main Form Content
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
                    
                    // Bottom padding for floating button
                    Color.clear
                        .frame(height: 80)
                        .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.mainBackground)
                
                // Floating Save Button
                FloatingSaveButton(
                    isEnabled: canSave,
                    action: {
                        isEditMode ? updateTransaction() : saveTransaction()
                    }
                )
                .padding(.horizontal, 15)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 8 : 20)
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            }
            .navigationTitle(isEditMode ? "Edit Transaction" : selectedType.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                // Keyboard toolbar - только кнопка скрыть клавиатуру
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isAmountFieldFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
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
        // Use preselected account if provided, otherwise use preferred account
        if let preselected = preselectedAccount {
            selectedAccount = preselected
            fromAccount = preselected
        } else {
            selectedAccount = userPreferences.getPreferredAccount(from: accounts)
            fromAccount = selectedAccount
        }
        
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

// MARK: - Floating Save Button Component

struct FloatingSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Save")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        isEnabled
                        ? AccountColors.color(at: 0)
                        : Color.gray.opacity(0.3)
                    )
            }
            .shadow(
                color: isEnabled
                ? AccountColors.color(at: 0).opacity(0.3)
                : Color.clear,
                radius: 12,
                y: 4
            )
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
