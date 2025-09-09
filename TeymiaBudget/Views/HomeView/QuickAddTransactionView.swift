import SwiftUI

struct QuickAddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var amount: String = ""
    @State private var isExpense: Bool = true
    @State private var selectedCategory: String = "Food"
    @State private var note: String = ""
    
    private let expenseCategories = ["Food", "Transport", "Shopping", "Bills", "Entertainment"]
    private let incomeCategories = ["Salary", "Freelance", "Investment", "Gift", "Other"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Type Toggle
                Picker("Type", selection: $isExpense) {
                    Text("Income").tag(false)
                    Text("Expense").tag(true)
                }
                .pickerStyle(.segmented)
                
                // Amount Input
                amountInput
                
                // Category Selection
                categorySelection
                
                // Note Input
                TextField("Note (optional)", text: $note)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
                
                // Save Button
                saveButton
            }
            .padding(20)
            .navigationTitle(isExpense ? "Add Expense" : "Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var amountInput: some View {
        HStack {
            Text("$")
                .font(.title)
                .foregroundColor(.secondary)
            
            TextField("0.00", text: $amount)
                .font(.title)
                .fontWeight(.semibold)
                .keyboardType(.decimalPad)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isExpense ? .red.opacity(0.1) : .green.opacity(0.1))
                .stroke(isExpense ? .red.opacity(0.3) : .green.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var categorySelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
            
            let categories = isExpense ? expenseCategories : incomeCategories
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedCategory == category ? .blue : .gray.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button {
            saveTransaction()
        } label: {
            Text(isExpense ? "Add Expense" : "Add Income")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isExpense ? .red : .green)
                )
        }
        .disabled(!canSave)
        .opacity(canSave ? 1.0 : 0.6)
    }
    
    private var canSave: Bool {
        !amount.isEmpty && Double(amount) != nil
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount) else { return }
        
        let transaction = Transaction(
            amount: Decimal(amountDouble),
            note: note.isEmpty ? nil : note,
            date: Date(),
            type: isExpense ? .expense : .income,
            category: nil, // Упростим пока без связи с категорией
            account: nil // Упростим пока без аккаунтов
        )
        
        modelContext.insert(transaction)
        try? modelContext.save()
        dismiss()
    }
}
