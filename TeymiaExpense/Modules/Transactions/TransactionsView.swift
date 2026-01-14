import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]
    
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    @Namespace private var transactionAnimation
    @Namespace private var animation
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                DateRangeHeader(startDate: $startDate, endDate: $endDate)
                
                // Transactions List
                if filteredTransactions.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "no_transactions".localized,
                            systemImage: "magnifyingglass"
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } else {
                    ForEach(sortedDates, id: \.self) { date in
                        Section {
                            ForEach(groupedTransactions[date] ?? []) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .matchedTransitionSource(id: transaction.id, in: transactionAnimation)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteTransaction(transaction)
                                        } label: {
                                            Label("", image: "trash.swipe")
                                        }
                                        .tint(.red)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingTransaction = transaction
                                    }
                            }
                        } header: {
                            DaySectionHeader(
                                date: date,
                                transactions: groupedTransactions[date] ?? [],
                                userPreferences: userPreferences
                            )
                        }
                    }
                }
            }
            .navigationTitle("transactions".localized)
            FloatingAddButton(action: { showingAddTransaction = true }, namespace: animation)
            .adaptiveSheet(item: $editingTransaction) { transaction in
                AddTransactionView(editingTransaction: transaction)
                    .navigationTransition(.zoom(sourceID: transaction.id, in: transactionAnimation))
            }
            .adaptiveSheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .navigationTransition(.zoom(sourceID: "ADDTRANSACTION", in: animation))
            }
        }
    }
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return allTransactions.filter { transaction in
            transaction.date >= startOfStartDate && transaction.date < endOfEndDate
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.snappy) {
            TransactionService.revertBalanceChanges(for: transaction)
            modelContext.delete(transaction)
            try? modelContext.save()
        }
    }
}

// MARK: - Day Section Header

struct DaySectionHeader: View {
    let date: Date
    let transactions: [Transaction]
    let userPreferences: UserPreferences
    
    private var dailyExpenses: Decimal {
        transactions
            .filter { $0.type == .expense }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var dateHeaderText: String {
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
    
    var body: some View {
        HStack {
            Text(dateHeaderText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if dailyExpenses != 0 {
                Text(userPreferences.formatAmount(dailyExpenses))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
            }
        }
        .padding(4)
        .textCase(nil)
    }
}
