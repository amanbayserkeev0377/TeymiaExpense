import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    
    // Transaction types
    enum TransactionType: String, CaseIterable {
        case expense = "Expense"
        case income = "Income"
        case transfer = "Transfer"
        
        var color: Color {
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
                colors: [color, lightColor],
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
    
    @State private var selectedTransactionType: TransactionType = .expense
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showKeypad = false
    @State private var showingCategorySelection = false
    
    // Transfer specific
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Transaction Type Picker
                    customTransactionTypePicker
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.clear)
                    
                    Form {
                        // Amount Section
                        Section {
                            HStack {
                                Text(currencySymbol)
                                    .foregroundStyle(.secondary)
                                    .font(.title2)
                                
                                Text(amount.isEmpty ? "0.00" : amount)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(amount.isEmpty ? .secondary : .primary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showKeypad = true
                                        }
                                    }
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                        
                        // Category Section (only for income/expense)
                        if selectedTransactionType != .transfer {
                            categorySection
                        }
                        
                        // Account/Transfer Section
                        if selectedTransactionType == .transfer {
                            transferSection
                        } else {
                            accountSection
                        }
                        
                        // Date & Note
                        Section("Details") {
                            DatePicker("Date", selection: $date, displayedComponents: [.date])
                            
                            TextField("Note (optional)", text: $note, axis: .vertical)
                                .lineLimit(2...4)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    if showKeypad {
                        Spacer()
                            .frame(height: 280)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    if showKeypad {
                        CustomNumericKeypad(
                            amount: $amount,
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showKeypad = false
                                }
                            })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(.clear)
            }
            .navigationTitle(selectedTransactionType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
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
            selectedCategory = nil // Reset category when changing type
        }
        .sheet(isPresented: $showingCategorySelection) {
            CategoryPickerView(
                transactionType: selectedTransactionType,
                selectedCategory: selectedCategory
            ) { category in
                selectedCategory = category
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(40)
        }
    }
        
    // MARK: - Transaction Type Picker
    private var customTransactionTypePicker: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases, id: \.self) { type in
                transactionTypeButton(for: type)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.gray.opacity(0.1))
        )
    }
    
    // MARK: - Transaction Type Button
    private func transactionTypeButton(for type: TransactionType) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTransactionType = type
            }
        } label: {
            HStack {
                Image(type.customIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedTransactionType == type ? .white : type.color)
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(selectedTransactionType == type ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(selectedTransactionType == type ? AnyShapeStyle(type.backgroundGradient.opacity(0.8)) : AnyShapeStyle(Color.clear))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Category Section
    @ViewBuilder
    private var categorySection: some View {
        Section("Category") {
            Button {
                showingCategorySelection = true
            } label: {
                HStack {
                    if let category = selectedCategory {
                        // Selected category
                        Image(category.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(selectedTransactionType.color)
                        
                        Text(category.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        // No category selected
                        Image(systemName: "folder")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        Text("Select Category")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .buttonStyle(.plain)
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
                                .foregroundColor(selectedAccount == account ? selectedTransactionType.color : .secondary)
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
                                    .foregroundColor(selectedTransactionType.color)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
        
        let expenseTransaction = Transaction(
            amount: -amount,
            note: note.isEmpty ? "Transfer to \(toAcc.name)" : note,
            date: date,
            type: .expense,
            category: nil,
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
