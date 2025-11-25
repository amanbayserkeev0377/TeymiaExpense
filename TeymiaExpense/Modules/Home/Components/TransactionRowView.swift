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
            
            // Transaction details (left side)
            VStack(alignment: .leading, spacing: 2) {
                // Title
                Text(transaction.displayTitle(relativeTo: nil))
                    .font(.body)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                // Account name (moved from right)
                if let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Note (if exists)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount (right side - simple)
            Text(transaction.formattedAmount(for: transaction.account))
                .font(.body)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(transaction.typeColor)
        }
        .contentShape(Rectangle())
    }
}
