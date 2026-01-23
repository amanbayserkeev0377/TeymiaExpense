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
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 70)
            }
            .navigationTitle("transactions".localized)
            FloatingAddButton(action: { showingAddTransaction = true }, namespace: animation)
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(editingTransaction: transaction)
                    .navigationTransition(.zoom(sourceID: transaction.id, in: transactionAnimation))
            }
            .sheet(isPresented: $showingAddTransaction) {
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
    var currentAccount: Account? = nil
    
    private var dailyTotal: Decimal {
        transactions.reduce(Decimal.zero) { sum, transaction in
            if let account = currentAccount {
                return sum + transaction.amountForAccount(account)
            } else {
                guard transaction.type != .transfer else { return sum }
                
                let converted = CurrencyService.shared.convert(
                    abs(transaction.amount),
                    from: transaction.account?.currencyCode ?? "USD",
                    to: userPreferences.baseCurrencyCode
                )
                
                return transaction.type == .income ? sum + converted : sum - converted
            }
        }
    }
    
    private var dateHeaderText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "today".localized }
        if calendar.isDateInYesterday(date) { return "yesterday".localized }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Text(dateHeaderText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if dailyTotal != 0 {
                Text(formatDisplayAmount(dailyTotal))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
            }
        }
        .padding(4)
        .textCase(nil)
    }
    
    private func formatDisplayAmount(_ amount: Decimal) -> String {
        if let account = currentAccount {
            return CurrencyFormatter.format(amount, currency: account.currency)
        } else {
            return userPreferences.formatAmount(amount)
        }
    }
}
