import SwiftUI
import SwiftData

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(transaction.displayIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
            
            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.displayTitle(relativeTo: nil))
                    .font(.body)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                // Show group name for regular transactions
                if transaction.type != .transfer,
                   let categoryGroup = transaction.category?.categoryGroup {
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
            }
            
            Spacer()
            
            // Amount and account
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount(for: transaction.account))
                    .font(.body)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(transaction.typeColor)
                
                if transaction.type != .transfer, let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
    }
}
