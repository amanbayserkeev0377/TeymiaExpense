import SwiftUI
import SwiftData

struct AccountTransactionsView: View {
    let account: Account
    
    @Query private var allTransactions: [Transaction]
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var startDate: Date = .startOfCurrentMonth
    @State private var endDate: Date = .endOfCurrentMonth
    
    @Namespace private var animation
    @Namespace private var transactionAnimation
    
    // Filter transactions for this account and date range
    private var filteredTransactions: [Transaction] {
        allTransactions.filter { transaction in
            let belongsToAccount = transaction.account?.id == account.id ||
                                  transaction.toAccount?.id == account.id
            let inDateRange = transaction.date >= startDate && transaction.date <= endDate
            return belongsToAccount && inDateRange
        }
        .sorted { $0.date > $1.date }
    }
    
    // Group by date
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    // Date range text
    private var dateRangeText: String {
        DateFormatter.formatDateRange(startDate: startDate, endDate: endDate)
    }
    
    var body: some View {
        NavigationStack {
            List {
                DateRangeHeader(startDate: $startDate, endDate: $endDate)
                transactionsSection
            }
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()
                
                AddToolbarButton {
                    showingAddTransaction = true
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(preselectedAccount: account)
                    .navigationTransition(.zoom(sourceID: "ADDTRANSACTION", in: animation))
            }
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(editingTransaction: transaction)
                    .navigationTransition(.zoom(
                        sourceID: transaction.id,
                        in: transactionAnimation
                    ))
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var transactionsSection: some View {
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
                
                Section {
                    ForEach(transactionsForDate) { transaction in
                        TransactionRowView(transaction: transaction, currentAccount: account)
                            .matchedTransitionSource(
                                id: transaction.id,
                                in: transactionAnimation
                            )
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteTransaction(transaction)
                                } label: {
                                    Image("trash.swipe")
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
                            transactions: transactionsForDate,
                            userPreferences: userPreferences,
                            currentAccount: account
                        )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            return "today".localized
        } else if calendar.isDateInYesterday(date) {
            return "yesterday".localized
        } else {
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
