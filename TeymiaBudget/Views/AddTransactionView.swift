//
//  AddTransactionView.swift
//  TeymiaBudget
//
//  Forms for adding income and expense transactions
//

import SwiftUI
import SwiftData

// MARK: - Add Income View
struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query private var allCategories: [Category]
    
    private var incomeCategories: [Category] {
        allCategories.filter { $0.type == .income }
    }
    
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var note: String = ""
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Amount Input Section
                amountInputSection
                
                // Account Selection
                accountSelectionSection
                
                // Category Selection
                categorySelectionSection
                
                // Note Input
                noteInputSection
                
                // Date Selection
                dateSelectionSection
                
                Spacer()
                
                // Save Button
                saveButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
    
    // MARK: - Amount Input
    private var amountInputSection: some View {
        VStack(spacing: 8) {
            Text("Amount")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(selectedAccount?.currency.symbol ?? "$")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.green.opacity(0.1))
                    .stroke(.green.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Account Selection
    private var accountSelectionSection: some View {
        VStack(spacing: 12) {
            Text("Account")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(accounts) { account in
                        AccountOptionView(
                            account: account,
                            isSelected: selectedAccount?.id == account.id
                        ) {
                            selectedAccount = account
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Category Selection
    private var categorySelectionSection: some View {
        VStack(spacing: 12) {
            Text("Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(incomeCategories) { category in
                    CategoryOptionView(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - Note Input
    private var noteInputSection: some View {
        VStack(spacing: 8) {
            Text("Note (Optional)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Add a note...", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...3)
        }
    }
    
    // MARK: - Date Selection
    private var dateSelectionSection: some View {
        VStack(spacing: 8) {
            Text("Date")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker("Transaction Date", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveTransaction) {
            Text("Add Income")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.gradient)
                )
        }
        .disabled(!canSave)
        .opacity(canSave ? 1.0 : 0.6)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Methods
    private func setupDefaults() {
        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        selectedCategory = incomeCategories.first
    }
    
    private var canSave: Bool {
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedAccount != nil &&
        selectedCategory != nil
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount),
              let account = selectedAccount,
              let category = selectedCategory else { return }
        
        let transaction = Transaction(
            amount: Decimal(amountDouble),
            note: note.isEmpty ? nil : note,
            date: date,
            type: .income,
            category: category,
            account: account
        )
        
        // Update account balance
        account.balance += Decimal(amountDouble)
        
        modelContext.insert(transaction)
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Add Expense View
struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query private var allCategories: [Category]
    
    private var expenseCategories: [Category] {
        allCategories.filter { $0.type == .expense }
    }
    
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var note: String = ""
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Amount Input Section
                amountInputSection
                
                // Account Selection
                accountSelectionSection
                
                // Category Selection
                categorySelectionSection
                
                // Note Input
                noteInputSection
                
                // Date Selection
                dateSelectionSection
                
                Spacer()
                
                // Save Button
                saveButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
    
    // MARK: - Amount Input
    private var amountInputSection: some View {
        VStack(spacing: 8) {
            Text("Amount")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(selectedAccount?.currency.symbol ?? "$")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red.opacity(0.1))
                    .stroke(.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Account Selection
    private var accountSelectionSection: some View {
        VStack(spacing: 12) {
            Text("Account")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(accounts) { account in
                        AccountOptionView(
                            account: account,
                            isSelected: selectedAccount?.id == account.id
                        ) {
                            selectedAccount = account
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Category Selection
    private var categorySelectionSection: some View {
        VStack(spacing: 12) {
            Text("Category")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(expenseCategories) { category in
                    CategoryOptionView(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - Note Input
    private var noteInputSection: some View {
        VStack(spacing: 8) {
            Text("Note (Optional)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Add a note...", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...3)
        }
    }
    
    // MARK: - Date Selection
    private var dateSelectionSection: some View {
        VStack(spacing: 8) {
            Text("Date")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker("Transaction Date", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveTransaction) {
            Text("Add Expense")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.red.gradient)
                )
        }
        .disabled(!canSave)
        .opacity(canSave ? 1.0 : 0.6)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Methods
    private func setupDefaults() {
        selectedAccount = accounts.first { $0.isDefault } ?? accounts.first
        selectedCategory = expenseCategories.first
    }
    
    private var canSave: Bool {
        !amount.isEmpty &&
        Double(amount) != nil &&
        selectedAccount != nil &&
        selectedCategory != nil
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount),
              let account = selectedAccount,
              let category = selectedCategory else { return }
        
        let transaction = Transaction(
            amount: -Decimal(amountDouble), // Negative for expense
            note: note.isEmpty ? nil : note,
            date: date,
            type: .expense,
            category: category,
            account: account
        )
        
        // Update account balance
        account.balance -= Decimal(amountDouble)
        
        modelContext.insert(transaction)
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Add Transfer View (Placeholder)
struct AddTransferView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Transfer Between Accounts")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Coming soon...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Add Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct AccountOptionView: View {
    let account: Account
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForAccountType(account.type))
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(account.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .frame(width: 80, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .blue : .gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bankAccount: return "building.columns"
        case .creditCard: return "creditcard"
        case .savings: return "bag"
        }
    }
}

struct CategoryOptionView: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? .blue : (Color(hex: category.colorHex) ?? .gray))
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
                    .fill(isSelected ? .blue.opacity(0.1) : .clear)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
