import SwiftUI

struct TransactionsListView: View {
    let transactions: [Transaction]
    @Binding var startDate: Date
    @Binding var endDate: Date
    let userPreferences: UserPreferences
    let currencies: [Currency]
    let onEditTransaction: (Transaction) -> Void
    let onHideTransaction: (Transaction) -> Void
    let onDeleteTransaction: (Transaction) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            TransactionsHeaderView(
                startDate: $startDate,
                endDate: $endDate
            )
            
            if transactions.isEmpty {
                TransactionEmptyStateView()
            } else {
                GroupedTransactionsList(
                    transactions: transactions,
                    userPreferences: userPreferences,
                    currencies: currencies,
                    onEditTransaction: onEditTransaction,
                    onHideTransaction: onHideTransaction,
                    onDeleteTransaction: onDeleteTransaction
                )
            }
        }
    }
}

// MARK: - Transactions Header
struct TransactionsHeaderView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    private var dateRangeText: String {
        DateFormatter.formatDateRange(startDate: startDate, endDate: endDate)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Transaction History")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(dateRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Date Filter Menu
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
}

// MARK: - Grouped Transactions List
struct GroupedTransactionsList: View {
    let transactions: [Transaction]
    let userPreferences: UserPreferences
    let currencies: [Currency]
    let onEditTransaction: (Transaction) -> Void
    let onHideTransaction: (Transaction) -> Void
    let onDeleteTransaction: (Transaction) -> Void
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(sortedDates, id: \.self) { date in
                DayTransactionsView(
                    date: date,
                    transactions: groupedTransactions[date] ?? [],
                    userPreferences: userPreferences,
                    currencies: currencies,
                    onEditTransaction: onEditTransaction,
                    onHideTransaction: onHideTransaction,
                    onDeleteTransaction: onDeleteTransaction
                )
            }
        }
    }
}

// MARK: - Day Transactions View
struct DayTransactionsView: View {
    let date: Date
    let transactions: [Transaction]
    let userPreferences: UserPreferences
    let currencies: [Currency]
    let onEditTransaction: (Transaction) -> Void
    let onHideTransaction: (Transaction) -> Void
    let onDeleteTransaction: (Transaction) -> Void
    
    private var dayTotal: Decimal {
        transactions.reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var dateHeaderText: String {
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
    
    var body: some View {
        VStack(spacing: 12) {
            // Date Header
            HStack {
                Text(dateHeaderText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(userPreferences.formatAmount(dayTotal, currencies: currencies))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(dayTotal >= 0 ? .green : .red)
            }
            .padding(.horizontal, 4)
            
            // Transactions for this date
            LazyVStack(spacing: 8) {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .glassEffect(.regular.interactive().tint(.mainRowBackground), in: RoundedRectangle(cornerRadius: 24))
                        .onTapGesture {
                            onEditTransaction(transaction)
                        }
                        .swipeActions {
                            // Edit action
                            Action(
                                imageName: "edit",
                                tint: .white,
                                background: .blue,
                                size: .init(width: 50, height: 50)
                            ) { resetPosition in
                                onEditTransaction(transaction)
                                resetPosition.toggle()
                            }
                            
                            // Hide action
                            Action(
                                imageName: "eye.crossed",
                                tint: .white,
                                background: .gray,
                                size: .init(width: 50, height: 50)
                            ) { resetPosition in
                                onHideTransaction(transaction)
                                resetPosition.toggle()
                            }
                            
                            // Delete action
                            Action(
                                imageName: "trash",
                                tint: .white,
                                background: .red,
                                size: .init(width: 50, height: 50)
                            ) { resetPosition in
                                onDeleteTransaction(transaction)
                                resetPosition.toggle()
                            }
                        }
                }
            }
        }
    }
}
