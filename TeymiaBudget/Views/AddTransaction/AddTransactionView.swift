import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var accounts: [Account]
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
    @State private var selectedSubcategory: Subcategory?
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showingCategorySelection = false
    
    // Transfer specific
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $selectedTransactionType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                
                // Amount Section
                Section {
                    HStack {
                        Text(currencySymbol)
                            .foregroundStyle(.secondary)
                            .font(.system(.title2, design: .rounded))

                        TextField("0", text: $amount)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.semibold)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Category Section (only for income/expense)
                if selectedTransactionType != .transfer {
                    Section {
                        NavigationLink {
                            CategorySelectionView(
                                transactionType: selectedTransactionType,
                                selectedCategory: selectedCategory,
                                selectedSubcategory: selectedSubcategory,
                                onSelectionChanged: { category, subcategory in
                                    selectedCategory = category
                                    selectedSubcategory = subcategory
                                }
                            )
                        } label: {
                            CategorySelectionRow(
                                selectedCategory: selectedCategory,
                                selectedSubcategory: selectedSubcategory
                            )
                        }
                    }
                }
                
                // Account/Transfer Section
                if selectedTransactionType == .transfer {
                    transferSection
                } else {
                    accountSection
                }
                
                // Date & Note
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle(selectedTransactionType.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupDefaults()
        }
        .onChange(of: selectedTransactionType) { _, _ in
            let categoryType: CategoryType = selectedTransactionType == .income ? .income : .expense
            selectedCategory = categories.first { $0.name.lowercased().contains("other") && $0.type == categoryType }
        }
    }
    
    // MARK: - Account Section
    @ViewBuilder
    private var accountSection: some View {
        Section("Account") {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "No Accounts",
                    systemImage: "wallet.bifold",
                    description: Text("Create your first account to get started")
                )
                .frame(height: 100)
            } else {
                ForEach(accounts) { account in
                    Button {
                        selectedAccount = account
                    } label: {
                        HStack {
                            Image(systemName: systemIconForAccountType(account.type))
                                .foregroundColor(selectedAccount == account ? .primary : .secondary)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.name)
                                    .foregroundColor(.primary)
                                
                                Text(formatCurrency(account.balance, currency: account.currency))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedAccount == account {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.primary)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
    
    }
    
    // MARK: - Transfer Section
    @ViewBuilder
    private var transferSection: some View {
        Section("From Account") {
            if accounts.count < 2 {
                Text("Need at least 2 accounts for transfers")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(accounts) { account in
                    Button {
                        fromAccount = account
                        if toAccount == account {
                            toAccount = nil
                        }
                    } label: {
                        HStack {
                            Image(systemName: systemIconForAccountType(account.type))
                                .foregroundColor(fromAccount == account ? .blue : .secondary)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.name)
                                    .foregroundColor(.primary)
                                
                                Text(formatCurrency(account.balance, currency: account.currency))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if fromAccount == account {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
        
        Section("To Account") {
            ForEach(accounts.filter { $0 != fromAccount }) { account in
                Button {
                    toAccount = account
                } label: {
                    HStack {
                        Image(systemName: systemIconForAccountType(account.type))
                            .foregroundColor(toAccount == account ? .blue : .secondary)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .foregroundColor(.primary)
                            
                            Text(formatCurrency(account.balance, currency: account.currency))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if toAccount == account {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
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
            return selectedAccount != nil && (selectedCategory != nil || selectedSubcategory != nil)
        case .transfer:
            return fromAccount != nil && toAccount != nil && fromAccount != toAccount
        }
    }
    
    // MARK: - Helper Methods
    private func systemIconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bankAccount: return "building.columns"
        case .creditCard: return "creditcard"
        case .savings: return "piggybank"
        }
    }
    
    private func setupDefaults() {
        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        fromAccount = accounts.first { $0.isDefault } ?? accounts.first
        
        // Default category "Other"
        if selectedCategory == nil {
            let categoryType: CategoryType = selectedTransactionType == .income ? .income : .expense
            selectedCategory = categories.first { $0.name.lowercased().contains("other") && $0.type == categoryType }
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
        guard let account = selectedAccount else { return }
        
        let transaction = Transaction(
            amount: -amount,
            note: note.isEmpty ? nil : note,
            date: date,
            type: .expense,
            category: selectedCategory,
            subcategory: selectedSubcategory,
            account: account
        )
        
        account.balance -= amount
        modelContext.insert(transaction)
        
        try? modelContext.save()
        dismiss()
    }
    
    private func saveIncomeTransaction(amount: Decimal) {
        guard let account = selectedAccount else { return }
        
        let transaction = Transaction(
            amount: amount,
            note: note.isEmpty ? nil : note,
            date: date,
            type: .income,
            category: selectedCategory,
            subcategory: selectedSubcategory,
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
            category: nil,
            subcategory: nil,
            account: fromAcc
        )
        
        let incomeTransaction = Transaction(
            amount: amount,
            note: note.isEmpty ? "Transfer from \(fromAcc.name)" : note,
            date: date,
            type: .income,
            category: nil,
            subcategory: nil,
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
