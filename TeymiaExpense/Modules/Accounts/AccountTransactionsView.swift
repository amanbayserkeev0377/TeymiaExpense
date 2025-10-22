import SwiftUI
import SwiftData

struct AccountTransactionsView: View {
    let account: Account
    
    @Query private var allTransactions: [Transaction]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
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
            return belongsToAccount && inDateRange && !transaction.isHidden
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
            .scrollContentBackground(.hidden)
            .background(.mainBackground)
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(preselectedAccount: account)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(editingTransaction: transaction)
                    .presentationDragIndicator(.visible)
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
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                CustomMenuView(style: .glass) {
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
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var transactionsSection: some View {
        if filteredTransactions.isEmpty {
            Section {
                TransactionEmptyStateView()
            }
            .listRowBackground(Color.clear)
        } else {
            ForEach(sortedDates, id: \.self) { date in
                Section {
                    ForEach(groupedTransactions[date] ?? [], id: \.id) { transaction in
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
                    Text(formatDate(date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
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
                .frame(width: 24, height: 24)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayTitle(relativeTo: currentAccount))
                    .font(.body)
                    .foregroundStyle(.primary)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(transaction.formattedAmount(for: currentAccount))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.typeColor)
        }
        .padding(.vertical, 4)
    }
}
