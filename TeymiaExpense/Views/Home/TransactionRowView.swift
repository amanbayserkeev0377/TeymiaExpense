import SwiftUI
import SwiftData

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Group {
                if transaction.type == .transfer {
                    Image("transfer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primary)
                } else if let category = transaction.category {
                    Image(category.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primary)
                } else {
                    // Fallback icon
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                if transaction.type == .transfer {
                    // Transfer title: "Account1 → Account2"
                    if let fromAccount = transaction.account,
                       let toAccount = transaction.toAccount {
                        Text("\(fromAccount.name) → \(toAccount.name)")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Transfer")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                } else {
                    Text(transaction.category?.name ?? "Unknown")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    // Show group name for regular transactions
                    if let categoryGroup = transaction.category?.categoryGroup {
                        Text(categoryGroup.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Note
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount and account
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatAmount(transaction.amount, currency: transaction.account?.currency))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor(for: transaction))
                
                if transaction.type != .transfer, let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    private func amountColor(for transaction: Transaction) -> Color {
        switch transaction.type {
        case .expense: return .red
        case .income: return .green
        case .transfer: return .blue
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
