import SwiftUI
import SwiftData

struct TransactionHistoryView: View {
    @Query private var transactions: [Transaction]
    
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
            .listStyle(.grouped)
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
            Group {
                if let category = transaction.category {
                    Image(category.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "arrow.left.arrow.right")
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Transfer")
                    .font(.body)
                    .fontWeight(.medium)
                
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatAmount(transaction.amount, currency: transaction.account?.currency))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(amountColor(for: transaction))
                
                if let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func colorForTransaction(_ transaction: Transaction) -> Color {
        if transaction.category == nil {
            return .blue // Transfer
        }
        
        switch transaction.type {
        case .expense: return .red
        case .income: return .green
        }
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
