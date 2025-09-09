import SwiftUI

struct TransactionHistoryView: View {
    var body: some View {
        Text("All Transactions")
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon placeholder
            Image("icon_category_food")
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatAmount(transaction.amount, isExpense: transaction.type == .expense))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .expense ? .red : .green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func formatAmount(_ amount: Decimal, isExpense: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
        return isExpense ? "-\(formatted)" : "+\(formatted)"
    }
}
