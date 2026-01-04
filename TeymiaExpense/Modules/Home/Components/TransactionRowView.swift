import SwiftUI
import SwiftData

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 0) {
            Image(transaction.displayIcon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
                .padding(.trailing, 12)
            
            if transaction.type == .transfer {
                Text(transaction.displayTitle(relativeTo: nil))
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(transaction.displayTitle(relativeTo: nil))
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let note = transaction.note, !note.isEmpty {
                            Text("(\(note))")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if let account = transaction.account {
                        Text(account.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
            
            Text(transaction.formattedAmount(for: transaction.account))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.typeColor)
        }
        .contentShape(Rectangle())
    }
}
