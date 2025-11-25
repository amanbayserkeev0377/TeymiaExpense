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
                    }
                    .listRowBackground(Color.mainRowBackground)
                    
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
                    
                    // Category Section (grid selection)
                    if selectedType != .transfer {
                        Section {
                            CategoryGridSelector(
                                categories: filteredCategories,
                                selectedCategory: $selectedCategory,
                                colorScheme: colorScheme
                            )
                        } header: {
                            Text("Category")
                        }
                        .listRowBackground(Color.mainRowBackground)
                    }
                    
                    // Date & Note
                    DateNoteSection(date: $date, note: $note)
                    
                    // Spacer for button
                    Color.clear
                        .frame(height: 80)
                        .listRowBackground(Color.clear)
                }
                .scrollDismissesKeyboard(.immediately)
                .scrollContentBackground(.hidden)
                .background(Color.mainGroupBackground)
                
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
            .navigationTitle(isEditMode ? "Edit Transaction" : "New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 280)
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
                .presentationCornerRadius(40)
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

// MARK: - Category Grid Selector

struct CategoryGridSelector: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let colorScheme: ColorScheme
    
    var body: some View {
        if categories.isEmpty {
            Text("No categories available")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
        } else {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 16
            ) {
                ForEach(categories) { category in
                    CategoryCircleButton(
                        category: category,
                        isSelected: selectedCategory?.id == category.id,
                        colorScheme: colorScheme
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Circle Button

struct CategoryCircleButton: View {
    let category: Category
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(
                        isSelected
                        ? (colorScheme == .light ? Color.white : Color.black)
                        : Color.primary
                    )
                    .padding(14)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.primary : Color.secondary.opacity(0.07))
                    )
                
                Text(category.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Floating Save Button Component

struct FloatingSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    private var buttonColor: Color {
        isEnabled ? .appTint : .gray.opacity(0.3)
    }
    
    private var shadowColor: Color {
        isEnabled ? .appTint.opacity(0.3) : .clear
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
