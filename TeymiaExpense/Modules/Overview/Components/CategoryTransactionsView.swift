import SwiftUI
import SwiftData

struct CategoryTransactionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    
    let category: Category
    let startDate: Date
    let endDate: Date
    
    @State private var editingTransaction: Transaction?
    
    @Namespace private var animation
    @Namespace private var transactionAnimation
    
    // Filter transactions for this category and date range
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return (category.transactions ?? []).filter { transaction in
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
            Section {
                HStack {
                    Text(DateFormatter.formatDateRange(startDate: startDate, endDate: endDate))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.type == .income ? "income".localized : "expense".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text(userPreferences.formatAmount(totalAmount))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(category.type == .income ? Color("IncomeColor").gradient : Color("ExpenseColor").gradient)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("transactions".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("\(filteredTransactions.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // Transactions List
            if filteredTransactions.isEmpty {
                Section {
                    ContentUnavailableView(
                        "no_transactions".localized,
                        systemImage: "magnifyingglass"
                    )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(sortedDates, id: \.self) { date in
                    let transactionsForDate = groupedTransactions[date] ?? []
                    let dailyTotal = transactionsForDate.reduce(Decimal.zero) { $0 + $1.amount }
                    
                    Section {
                        ForEach(transactionsForDate) { transaction in
                            TransactionRowView(transaction: transaction)
                                .matchedTransitionSource(
                                    id: transaction.id,
                                    in: transactionAnimation
                                )
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
                                }
                        }
                    } header: {
                        HStack {
                            Text(dateHeaderText(for: date))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(userPreferences.formatAmount(dailyTotal))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)
                        }
                        .padding(4)
                        .textCase(nil)
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            BackToolbarButton()
        }
        .adaptiveSheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
                .navigationTransition(.zoom(
                    sourceID: transaction.id,
                    in: transactionAnimation
                ))
        }
    }
    
    // MARK: - Helper Methods
    
    private func dateHeaderText(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "today".localized
        } else if calendar.isDateInYesterday(date) {
            return "yesterday".localized
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
