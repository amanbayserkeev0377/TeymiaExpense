import SwiftUI

struct AccountTypeSelectionRow: View {
    @Binding var selectedAccountType: AccountType
    @Binding var selectedIcon: String
    let selectedColor: Color
    
    var body: some View {
        Menu {
            ForEach(AccountType.allCases, id: \.self) { type in
                Button {
                    selectedAccountType = type
                    selectedIcon = iconForAccountType(type)
                } label: {
                    HStack {
                        Image(iconForAccountType(type))
                        Text(type.displayName)
                    }
                }
            }
        } label: {
            HStack {
                Image(iconForAccountType(selectedAccountType))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedColor)
                
                Text(selectedAccountType.displayName)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }
        }
    }
    
    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "cash"
        case .bankAccount: return "bank"
        case .creditCard: return "credit.card"
        case .savings: return "piggy.bank"
        }
    }
}
