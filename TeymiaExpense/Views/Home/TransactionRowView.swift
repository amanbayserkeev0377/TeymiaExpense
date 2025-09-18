import SwiftUI
import SwiftData

struct TransactionHistoryView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(formatSectionDate(date))) {
                        ForEach(groupedTransactions[date] ?? []) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Group {
                if let category = transaction.category {
                    Image(category.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primary)
                } else {
                    // Transfer icon
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blue)
                        .frame(width: 24, height: 24)
                }
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Transfer")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                // Show group name for regular transactions
                if let categoryGroup = transaction.category?.categoryGroup {
                    Text(categoryGroup.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Note
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Time
                Text(transaction.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount and account
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatAmount(transaction.amount, currency: transaction.account?.currency))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor(for: transaction))
                
                if let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func amountColor(for transaction: Transaction) -> Color {
        switch transaction.type {
        case .expense: return .red
        case .income: return .green
        }
    }
    
    private func formatAmount(_ amount: Decimal, currency: Currency?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency?.code ?? "USD"
        formatter.currencySymbol = currency?.symbol ?? "$"
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency?.symbol ?? "$")0.00"
    }
}
