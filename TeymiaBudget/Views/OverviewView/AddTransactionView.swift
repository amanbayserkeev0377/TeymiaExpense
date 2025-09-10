import SwiftUI
import SwiftData

// MARK: - Add Transaction View with Custom Icon Picker
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    
    // Transaction types
    enum TransactionOption: String, CaseIterable {
        case expense = "Expense"
        case transfer = "Transfer"
        case income = "Income"
        
        var color: Color {
            switch self {
            case .expense: return .red
            case .transfer: return .blue
            case .income: return .green
            }
        }
        
        var iconName: String {
            switch self {
            case .expense: return "wallet-expense"
            case .transfer: return "money-transfer"
            case .income: return "wallet-income"
            }
        }
    }
    
    @State private var selectedType: TransactionOption = .expense
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var note: String = ""
    @State private var date: Date = Date()
    
    // Transfer specific
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Segmented Picker with Icons
                segmentedPicker
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Input
                        amountSection
                        
                        // Account/Transfer Section
                        if selectedType == .transfer {
                            transferSection
                        } else {
                            accountSection
                        }
                        
                        // Category Section (не показываем для Transfer)
                        if selectedType != .transfer {
                            categorySection
                        }
                        
                        // Note Section
                        noteSection
                        
                        // Date Section
                        dateSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
                
                // Save Button
                saveButtonSection
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            setupDefaults()
        }
    }
    
    // MARK: - Custom Segmented Picker
    private var segmentedPicker: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(TransactionOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = option
                            updateDefaultCategory()
                        }
                    } label: {
                        Image(option.iconName)
                            .renderingMode(.template)
                            .frame(width: 28, height: 28)
                            .foregroundColor(selectedType == option ? .white : option.color)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedType == option ? option.color : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.1))
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Divider
            Rectangle()
                .fill(.separator)
                .frame(height: 0.5)
        }
        .background(.regularMaterial)
    }
    
    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Amount")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 12) {
                Text(currencySymbol)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedType.color.opacity(0.1))
                    .stroke(selectedType.color.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Account Section (для Income/Expense)
    private var accountSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Account")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                NavigationLink {
                    AddAccountView()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Add")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            if accounts.isEmpty {
                // Empty state with link to add account
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No accounts available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    NavigationLink {
                        AddAccountView()
                    } label: {
                        Text("Create your first account")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.separator, lineWidth: 1)
                        )
                )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(accounts) { account in
                        accountButton(account: account, isSelected: selectedAccount?.id == account.id) {
                            selectedAccount = account
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Transfer Section
    private var transferSection: some View {
        VStack(spacing: 20) {
            // Add account link at the top if no accounts
            if accounts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("Need at least 2 accounts for transfers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        AddAccountView()
                    } label: {
                        Text("Create accounts")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.separator, lineWidth: 1)
                        )
                )
            }
            
            // From Account
            VStack(spacing: 12) {
                HStack {
                    Text("From Account")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    
                    NavigationLink {
                        AddAccountView()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.caption)
                            Text("Add")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(accounts) { account in
                        accountButton(account: account, isSelected: fromAccount?.id == account.id) {
                            fromAccount = account
                            // Reset toAccount if same as fromAccount
                            if toAccount?.id == account.id {
                                toAccount = nil
                            }
                        }
                    }
                }
            }
            
            // Arrow
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
            
            // To Account
            VStack(spacing: 12) {
                HStack {
                    Text("To Account")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(accounts.filter { $0.id != fromAccount?.id }) { account in
                        accountButton(account: account, isSelected: toAccount?.id == account.id) {
                            toAccount = account
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            let filteredCategories = categories.filter {
                $0.type == (selectedType == .income ? .income : .expense)
            }
            
            if filteredCategories.isEmpty {
                Text("No categories available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.1))
                    )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(filteredCategories) { category in
                        categoryButton(category: category, isSelected: selectedCategory?.id == category.id) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Note Section
    private var noteSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Note")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("(Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            TextField("Add a note...", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
    }
    
    // MARK: - Date Section
    private var dateSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Date")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            DatePicker("Transaction Date", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.separator)
                .frame(height: 0.5)
            
            VStack(spacing: 16) {
                Button {
                    saveTransaction()
                } label: {
                    HStack {
                        Image(selectedType.iconName)
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text("Add \(selectedType.rawValue)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedType.color.gradient)
                    )
                    .foregroundColor(.white)
                }
                .disabled(!canSave)
                .opacity(canSave ? 1.0 : 0.6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
    }
    
    // MARK: - Helper Views
    private func accountButton(account: Account, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: getSystemIconForAccountType(account.type))
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : selectedType.color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(formatCurrency(account.balance, currency: account.currency))
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? selectedType.color : .gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func categoryButton(category: Category, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(category.iconName)
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? selectedType.color : getCategoryColor(for: category))
                    )
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? selectedType.color.opacity(0.1) : .clear)
                    .stroke(isSelected ? selectedType.color : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    private var currencySymbol: String {
        if selectedType == .transfer {
            return fromAccount?.currency.symbol ?? "$"
        }
        return selectedAccount?.currency.symbol ?? "$"
    }
    
    private var canSave: Bool {
        guard !amount.isEmpty, Double(amount) != nil else { return false }
        
        switch selectedType {
        case .expense, .income:
            return selectedAccount != nil && selectedCategory != nil
        case .transfer:
            return fromAccount != nil && toAccount != nil && fromAccount?.id != toAccount?.id
        }
    }
    
    // MARK: - Helper Methods
    private func getSystemIconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bankAccount: return "building.columns"
        case .creditCard: return "creditcard"
        case .savings: return "piggybank"
        }
    }
    
    private func getCategoryColor(for category: Category) -> Color {
        // Default colors for different category types
        switch category.type {
        case .expense:
            return .red.opacity(0.8)
        case .income:
            return .green.opacity(0.8)
        }
    }
    
    private func setupDefaults() {
        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        fromAccount = accounts.first { $0.isDefault } ?? accounts.first
        
        // Set default category based on type
        updateDefaultCategory()
    }
    
    private func updateDefaultCategory() {
        let filteredCategories = categories.filter {
            $0.type == (selectedType == .income ? .income : .expense)
        }
        selectedCategory = filteredCategories.first
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
        
        switch selectedType {
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
            amount: -amount, // Negative for expense
            note: note.isEmpty ? nil : note,
            date: date,
            type: .expense,
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
        
        // Create two transactions for transfer
        let expenseTransaction = Transaction(
            amount: -amount,
            note: note.isEmpty ? "Transfer to \(toAcc.name)" : note,
            date: date,
            type: .expense,
            category: nil, // No category for transfers
            account: fromAcc
        )
        
        let incomeTransaction = Transaction(
            amount: amount,
            note: note.isEmpty ? "Transfer from \(fromAcc.name)" : note,
            date: date,
            type: .income,
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

#Preview {
    AddTransactionView()
}
