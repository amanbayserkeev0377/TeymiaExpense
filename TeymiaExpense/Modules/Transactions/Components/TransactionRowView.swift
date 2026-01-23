import SwiftUI
import SwiftData

struct TransactionRowView: View {
    let transaction: Transaction
    var currentAccount: Account? = nil
    
    private var iconColor: Color {
        if transaction.type == .transfer {
            return .transfer
        } else {
            return transaction.category?.iconColor.color ?? .color1
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            CategoryIconView(
                iconName: transaction.displayIcon,
                color: iconColor,
                size: 20
            )
            .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(transaction.displayTitle())
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    if let note = transaction.note, !note.isEmpty {
                        Text("(\(note))")
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                if transaction.type != .transfer, currentAccount == nil, let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            let displayAmount = currentAccount != nil ?
            transaction.amountForAccount(currentAccount!) :
            transaction.amount
            
            Text(CurrencyFormatter.format(abs(displayAmount), currency: currentAccount?.currency ?? transaction.account?.currency ?? .defaultUSD))
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(transaction.typeColor)
        }
        .contentShape(Rectangle())
    }
}
