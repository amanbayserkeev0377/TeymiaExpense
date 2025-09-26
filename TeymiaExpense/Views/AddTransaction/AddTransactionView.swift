import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var accounts: [Account]
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    
    enum TransactionType: String, CaseIterable {
        case expense = "Expense"
        case income = "Income"
        case transfer = "Transfer"
    }
    
    @State private var selectedTransactionType: TransactionType = .expense
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showingAddAccount = false
    @State private var showingCategorySelection = false
    
    @FocusState private var isAmountFieldFocused: Bool
    
    // Transfer specific
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("\(currencySymbol)", text: $amount)
                            .autocorrectionDisabled()
                            .focused($isAmountFieldFocused)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                    }
                    .contentShape(Rectangle())
                    
                    CustomSegmentedControl(
                        options: TransactionType.allCases,
                        titles: TransactionType.allCases.map { $0.rawValue },
                        icons: TransactionType.allCases.map { $0.customIconName },
                        gradients: TransactionType.allCases.map { $0.backgroundGradient },
                        selection: $selectedTransactionType
                    )
                }
                .listRowBackground(Color.mainRowBackground)
                
                // Category Section (only for income/expense)
                if selectedTransactionType != .transfer {
                    Section {
                        NavigationLink {
                            CategorySelectionView(
                                transactionType: selectedTransactionType,
                                selectedCategory: selectedCategory,
                                onSelectionChanged: { category in
                                    selectedCategory = category
                                }
                            )
                        } label: {
                            CategorySelectionRow(
                                selectedCategory: selectedCategory
                            )
                        }
                    }
                    .listRowBackground(Color.mainRowBackground)
                }
                
                // Account/Transfer Section
                if selectedTransactionType == .transfer {
                    transferSection
                } else {
                    accountSection
                }
                
                
                // Date & Note
                Section {
                    HStack {
                        Image("calendar.date")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                        DatePicker("date".localized, selection: $date, displayedComponents: [.date])
                    }
                    HStack {
                        Image("note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                        TextField("note".localized, text: $note, axis: .vertical)
                    }
                }
                .listRowBackground(Color.mainRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground.ignoresSafeArea())
            .navigationTitle(selectedTransactionType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isAmountFieldFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .fontWeight(.medium)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        saveTransaction()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            setupDefaults()
            DispatchQueue.main.async {
                isAmountFieldFocused = true
            }
        }
        .onChange(of: selectedTransactionType) { _, _ in
            setDefaultCategory()
        }
        .onChange(of: selectedTransactionType) { _, _ in
            setDefaultCategory()
            
            if selectedTransactionType == .transfer && accounts.count > 1 && toAccount == nil {
                toAccount = accounts.first { $0 != fromAccount }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Account Section
    @ViewBuilder
    private var accountSection: some View {
        Section("Account") {
            ForEach(accounts) { account in
                Button {
                    selectedAccount = account
                } label: {
                    HStack {
                        Image(account.cardIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(selectedAccount == account ? .primary : .secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .foregroundStyle(.primary)
                            
                            Text(formatCurrency(account.balance, currency: account.currency))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedAccount == account {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.app)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listRowBackground(Color.mainRowBackground)
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Transfer Section
    @ViewBuilder
    private var transferSection: some View {
        Section("From Account") {
            ForEach(accounts) { account in
                Button {
                    fromAccount = account
                    if toAccount == account {
                        toAccount = nil
                    }
                } label: {
                    HStack {
                        Image(account.cardIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(fromAccount == account ? .primary : .secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .foregroundStyle(.primary)
                            
                            Text(formatCurrency(account.balance, currency: account.currency))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if fromAccount == account {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.app)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listRowBackground(Color.mainRowBackground)
        .listStyle(.insetGrouped)
        
        Section("To Account") {
            let availableToAccounts = accounts.filter { $0 != fromAccount }
            
            if availableToAccounts.isEmpty {
                Button {
                    showingAddAccount = true
                } label: {
                    Label("Add another account for transfers", systemImage: "plus")
                        .foregroundStyle(.app)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            } else {
                ForEach(availableToAccounts) { account in
                    Button {
                        toAccount = account
                    } label: {
                        HStack {
                            Image(account.cardIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(toAccount == account ? .primary : .secondary)
                            
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.name)
                                    .foregroundStyle(.primary)
                                
                                Text(formatCurrency(account.balance, currency: account.currency))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if toAccount == account {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.app)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listRowBackground(Color.mainRowBackground)
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Computed Properties
    private var currencySymbol: String {
        if selectedTransactionType == .transfer {
            return fromAccount?.currency.symbol ?? "$"
        }
        return selectedAccount?.currency.symbol ?? "$"
    }
    
    private var canSave: Bool {
        guard !amount.isEmpty,
              let _ = Double(amount),
              Double(amount) ?? 0 > 0 else { return false }
        
        switch selectedTransactionType {
        case .expense, .income:
            return selectedAccount != nil && selectedCategory != nil
        case .transfer:
            return fromAccount != nil && toAccount != nil && fromAccount != toAccount
        }
    }
    
    // MARK: - Helper Methods
    private func setupDefaults() {
        // Selected account для expense/income
        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        
        // From account для transfer (всегда Main Account)
        fromAccount = accounts.first { $0.isDefault } ?? accounts.first
        
        // To account только если есть другие аккаунты
        if accounts.count > 1 {
            toAccount = accounts.first { !$0.isDefault }
        }
        
        // Default category based on transaction type
        if selectedCategory == nil {
            setDefaultCategory()
        }
    }
    
    private func setDefaultCategory() {
        if selectedTransactionType == .income {
            // For income: try to find "salary" -> "monthly.salary"
            selectedCategory = categories.first { category in
                category.categoryGroup.type == .income &&
                category.categoryGroup.name.lowercased().contains("salary") &&
                category.name.lowercased().contains("monthly.salary")
            }
            
            // Fallback: any income category from salary group
            if selectedCategory == nil {
                selectedCategory = categories.first { category in
                    category.categoryGroup.type == .income &&
                    category.categoryGroup.name.lowercased().contains("salary")
                }
            }
            
            // Ultimate fallback: first income category
            if selectedCategory == nil {
                selectedCategory = categories.first { $0.categoryGroup.type == .income }
            }
        } else {
            // For expense: find "other" -> "general"
            selectedCategory = categories.first { category in
                category.categoryGroup.type == .expense &&
                category.categoryGroup.name.lowercased().contains("other") &&
                category.name.lowercased().contains("general")
            }
            
            // Fallback: any expense category from other group
            if selectedCategory == nil {
                selectedCategory = categories.first { category in
                    category.categoryGroup.type == .expense &&
                    category.categoryGroup.name.lowercased().contains("other")
                }
            }
            
            // Ultimate fallback: first expense category
            if selectedCategory == nil {
                selectedCategory = categories.first { $0.categoryGroup.type == .expense }
            }
        }
    }
    
    private func formatCurrency(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)0.00"
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount) else { return }
        let decimalAmount = Decimal(amountDouble)
        
        switch selectedTransactionType {
        case .expense:
            saveExpenseTransaction(amount: decimalAmount)
        case .income:
            saveIncomeTransaction(amount: decimalAmount)
        case .transfer:
            saveTransferTransaction(amount: decimalAmount)
        }
    }
    
    private func saveExpenseTransaction(amount: Decimal) {
        guard let account = selectedAccount, let category = selectedCategory else { return }
        
        let transaction = Transaction(
            amount: -amount,
            note: note.isEmpty ? nil : note,
            date: date,
            type: .expense,
            categoryGroup: category.categoryGroup,
            category: category,
            account: account
        )
        
        account.balance -= amount
        modelContext.insert(transaction)
        
        try? modelContext.save()
        dismiss()
    }
    
    private func saveIncomeTransaction(amount: Decimal) {
        guard let account = selectedAccount, let category = selectedCategory else { return }
        
        let transaction = Transaction(
            amount: amount,
            note: note.isEmpty ? nil : note,
            date: date,
            type: .income,
            categoryGroup: category.categoryGroup,
            category: category,
            account: account
        )
        
        account.balance += amount
        modelContext.insert(transaction)
        
        try? modelContext.save()
        dismiss()
    }
    
    private func saveTransferTransaction(amount: Decimal) {
        guard let fromAcc = fromAccount, let toAcc = toAccount else { return }
        
        let expenseTransaction = Transaction(
            amount: -amount,
            note: note.isEmpty ? "Transfer to \(toAcc.name)" : note,
            date: date,
            type: .expense,
            categoryGroup: nil,
            category: nil,
            account: fromAcc
        )
        
        let incomeTransaction = Transaction(
            amount: amount,
            note: note.isEmpty ? "Transfer from \(fromAcc.name)" : note,
            date: date,
            type: .income,
            categoryGroup: nil,
            category: nil,
            account: toAcc
        )
        
        fromAcc.balance -= amount
        toAcc.balance += amount
        
        modelContext.insert(expenseTransaction)
        modelContext.insert(incomeTransaction)
        
        try? modelContext.save()
        dismiss()
    }
}

extension AddTransactionView.TransactionType {
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
            startPoint: .top,
            endPoint: .bottom
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
