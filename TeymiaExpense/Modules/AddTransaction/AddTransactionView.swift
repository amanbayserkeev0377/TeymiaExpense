import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    @Environment(\.colorScheme) private var colorScheme
    
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
    @FocusState private var isAmountFieldFocused: Bool
    @State private var isInitialized = false
    
    // Filtered categories based on transaction type
    private var filteredCategories: [Category] {
        categories.filter { category in
            switch selectedType {
            case .expense:
                return category.type == .expense
            case .income:
                return category.type == .income
            case .transfer:
                return false
            }
        }
        .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Initializers
    init(editingTransaction: Transaction? = nil, preselectedAccount: Account? = nil) {
        self.editingTransaction = editingTransaction
        self.preselectedAccount = preselectedAccount
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section {
                        HStack {
                            TextField(currencySymbol, text: $amount)
                                .autocorrectionDisabled()
                                .focused($isAmountFieldFocused)
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                        }
                        .contentShape(Rectangle())
                        
                        HStack {
                            Image("note")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.primary)
                            
                            TextField("note".localized, text: $note)
                                .fontDesign(.rounded)
                                
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                    note = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.secondary.opacity(0.5))
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(.plain)
                            .opacity(note.isEmpty ? 0 : 1)
                            .scaleEffect(note.isEmpty ? 0.001 : 1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: note.isEmpty)
                            .disabled(note.isEmpty)
                        }
                        .contentShape(Rectangle())
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
                    
                    // Catgories Section
                    if selectedType != .transfer {
                        Section("category".localized) {
                            CategoriesSection(
                                categories: filteredCategories,
                                selectedCategory: $selectedCategory,
                                colorScheme: colorScheme
                            )
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    
                    DateNoteSection(date: $date)
                    
                    // Spacer for button
                    Color.clear
                        .frame(height: 80)
                        .listRowBackground(Color.clear)
                }
                .scrollDismissesKeyboard(.immediately)
                
                // Floating button
                if isInitialized {
                    FloatingSaveButton(
                        isEnabled: canSave,
                        action: {
                            isEditMode ? updateTransaction() : saveTransaction()
                        }
                    )
                    .padding(.horizontal, 15)
                    .padding(.bottom, 10)
                    .transition(.opacity)
                }
            }
            .navigationTitle(isEditMode ? "edit_transaction".localized : "new_transaction".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()
                
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 270)
                }
            }
        }
        .onAppear { setupInitialValues() }
        .onChange(of: selectedType) { oldValue, newValue in
            handleTypeChange(from: oldValue, to: newValue)
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
    }
    
    // MARK: - Computed Properties
    
    private var currencySymbol: String {
        if selectedType == .transfer {
            return fromAccount?.currency?.symbol ?? "$"
        }
        return selectedAccount?.currency?.symbol ?? "$"
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) {
                isInitialized = true
            }
            isAmountFieldFocused = true
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
            from: filteredCategories
        )
    }
    
    private func handleTypeChange(from oldType: TransactionType, to newType: TransactionType) {
        // Update default category when switching types
        if newType != .transfer {
            selectedCategory = TransactionService.getDefaultCategory(
                for: newType,
                from: filteredCategories
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
        }
    }
}

// MARK: - Floating Save Button Component

struct FloatingSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    private var buttonColor: Color {
        isEnabled ? .primary : .gray.opacity(0.3)
    }
    
    private var shadowColor: Color {
        isEnabled ? .primary.opacity(0.3) : .clear
    }
    
    private var textColor: Color {
        isEnabled ? .white : .gray.opacity(0.6)
    }
    
    var body: some View {
        Button(action: action) {
            Text("Save")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(buttonColor)
                }
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: shadowColor, radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.3), value: isEnabled)
    }
}
