import SwiftUI
import SwiftData

// MARK: - Simplified Add Transaction View
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
        
        var icon: String {
            switch self {
            case .expense: return "icon_expense"
            case .transfer: return "icon_transfer"
            case .income: return "icon_income"
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
                // Type Segmented Picker
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
    
    // MARK: - Segmented Picker
    private var segmentedPicker: some View {
        VStack(spacing: 0) {
            Picker("Transaction Type", selection: $selectedType) {
                ForEach(TransactionOption.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
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
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(accounts) { account in
                    accountButton(account: account, isSelected: selectedAccount?.id == account.id) {
                        selectedAccount = account
                    }
                }
            }
        }
    }
    
    // MARK: - Transfer Section
    private var transferSection: some View {
        VStack(spacing: 20) {
            // From Account
            VStack(spacing: 12) {
                HStack {
                    Text("From Account")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(accounts) { account in
                        accountButton(account: account, isSelected: fromAccount?.id == account.id) {
                            fromAccount = account
                        }
                    }
                }
            }
            
            // Arrow
            Image("icon_arrow_down")
                .renderingMode(.template)
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(filteredCategories) { category in
                    categoryButton(category: category, isSelected: selectedCategory?.id == category.id) {
                        selectedCategory = category
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
                        Image(selectedType.icon)
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                        
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
                Image("icon_account_\(account.type.rawValue)")
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .white : selectedType.color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(formatCurrency(account.balance))
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
                Image("icon_category_\(category.iconName)")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? selectedType.color : (Color(hex: category.colorHex) ?? .gray))
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
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
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
            note: "Transfer to \(toAcc.name)",
            date: date,
            type: .expense,
            category: nil, // No category for transfers
            account: fromAcc
        )
        
        let incomeTransaction = Transaction(
            amount: amount,
            note: "Transfer from \(fromAcc.name)",
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

// MARK: - Color Extension (если еще не добавлена)
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    AddTransactionView()
}
