import SwiftUI
import SwiftData

struct CategoryTransactionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    
    let category: Category
    let startDate: Date
    let endDate: Date
    
    @State private var editingTransaction: Transaction?
    
    // Filter transactions for this category and date range
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return category.transactions.filter { transaction in
            !transaction.isHidden &&
            transaction.date >= startOfStartDate &&
            transaction.date < endOfEndDate
        }.sorted { $0.date > $1.date }
    }
    
    // Group transactions by date
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    private var totalAmount: Decimal {
        filteredTransactions.reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
    
    var body: some View {
        List {
            // Summary Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total \(category.categoryGroup.type == .income ? "Income" : "Expense")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(userPreferences.formatAmount(totalAmount, currencies: currencies))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(category.categoryGroup.type == .income ? .green : .red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Transactions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(filteredTransactions.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.mainRowBackground)
            
            // Transactions List
            if filteredTransactions.isEmpty {
                Section {
                    TransactionEmptyStateView()
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(sortedDates, id: \.self) { date in
                    Section {
                        ForEach(groupedTransactions[date] ?? []) { transaction in
                            TransactionRowView(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingTransaction = transaction
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteTransaction(transaction)
                                    } label: {
                                        Image("trash.swipe")
                                    }
                                    .tint(.red)
                                    
                                    Button {
                                        editingTransaction = transaction
                                    } label: {
                                        Image("edit")
                                    }
                                    .tint(.gray)
                                }
                        }
                    } header: {
                        Text(dateHeaderText(for: date))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .textCase(nil)
                    }
                    .listRowBackground(Color.mainRowBackground)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Methods
    
    private func dateHeaderText(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation {
            TransactionService.revertBalanceChanges(for: transaction)
            modelContext.delete(transaction)
            try? modelContext.save()
        }
    }
}
