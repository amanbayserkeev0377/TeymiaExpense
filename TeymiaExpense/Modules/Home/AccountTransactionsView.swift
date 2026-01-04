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
                dateFilterHeader
                transactionsSection
            }
            .listStyle(.plain)
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden)
            .background(BackgroundView())
            .toolbar {
                CloseToolbarButton()
                
                AddToolbarButton {
                    showingAddTransaction = true
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(preselectedAccount: account)
            }
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(editingTransaction: transaction)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var dateFilterHeader: some View {
        Section {
            HStack {
                Text(dateRangeText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                CustomMenuView() {
                    Image("calendar")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .frame(width: 40, height: 30)
                } content: {
                    DateFilterView(
                        startDate: $startDate,
                        endDate: $endDate
                    )
                }
                .padding(10)
            }
        }
        .listSectionSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
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
                let dayTotal = transactionsForDate.reduce(Decimal.zero) { sum, transaction in
                        sum + transaction.amountForAccount(account)
                    }
                Section {
                    ForEach(transactionsForDate) { transaction in
                        TransactionRow(transaction: transaction, currentAccount: account)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingTransaction = transaction
                            }
                            .swipeActions(edge: .trailing) {
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
                        Text(formatDate(date))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(userPreferences.formatAmount(dayTotal))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 4)
                    .textCase(nil)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
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

// MARK: - Transaction Row Component
struct TransactionRow: View {
    let transaction: Transaction
    let currentAccount: Account
    
    var body: some View {
        HStack(spacing: 12) {
            Image(transaction.displayIcon)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(.primary)
            
            HStack(spacing: 4) {
                Text(transaction.displayTitle(relativeTo: currentAccount))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
            
            Text(transaction.formattedAmount(for: currentAccount))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.typeColor)
        }
        .contentShape(Rectangle())
    }
}
