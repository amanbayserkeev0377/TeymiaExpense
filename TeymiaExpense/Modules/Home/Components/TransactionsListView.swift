import SwiftUI

struct GlassTransactionsListView: View {
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
            if transactions.isEmpty {
                TransactionEmptyStateView()
            } else {
                GlassGroupedTransactionsList(
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

// MARK: - Glass Grouped Transactions List

struct GlassGroupedTransactionsList: View {
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
                GlassDayTransactionsView(
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

// MARK: - Glass Day Transactions View (Unified Card)

struct GlassDayTransactionsView: View {
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateHeaderText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(userPreferences.formatAmount(dayTotal, currencies: currencies))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(dayTotal >= 0 ? Color("IncomeColor") : Color("ExpenseColor"))
            }
            .padding(.horizontal, 4)
            
            // Unified Glass Card со всеми транзакциями
            VStack(spacing: 0) {
                ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                    GlassTransactionRow(
                        transaction: transaction,
                        onEdit: { onEditTransaction(transaction) },
                        onHide: { onHideTransaction(transaction) },
                        onDelete: { onDeleteTransaction(transaction) }
                    )
                    
                    // Divider между транзакциями (кроме последней)
                    if index < transactions.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 10, opaque: true)
                    .background(Color.white.opacity(0.05))
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [
                            .white.opacity(0.5),
                            .clear,
                            .white.opacity(0.2),
                            .white.opacity(0.5)
                            
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: .black.opacity(0.1), radius: 10)
        }
    }
}

// MARK: - Glass Transaction Row (внутри unified card)

struct GlassTransactionRow: View {
    let transaction: Transaction
    let onEdit: () -> Void
    let onHide: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        TransactionRowView(transaction: transaction)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture {
                onEdit()
            }
            .swipeActions {
                // Hide action
                Action(
                    imageName: "eye.crossed",
                    tint: .white,
                    background: .gray,
                    size: .init(width: 40, height: 40)
                ) { resetPosition in
                    onHide()
                    resetPosition.toggle()
                }
                
                // Delete action
                Action(
                    imageName: "trash",
                    tint: .white,
                    background: .red,
                    size: .init(width: 40, height: 40)
                ) { resetPosition in
                    onDelete()
                    resetPosition.toggle()
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Background gradient
        Color.mainBackground
            .ignoresSafeArea()
        
        ScrollView {
            GlassTransactionsListView(
                transactions: [],
                startDate: .constant(Date.startOfCurrentMonth),
                endDate: .constant(Date.endOfCurrentMonth),
                userPreferences: UserPreferences(),
                currencies: [],
                onEditTransaction: { _ in },
                onHideTransaction: { _ in },
                onDeleteTransaction: { _ in }
            )
            .padding()
        }
    }
}
