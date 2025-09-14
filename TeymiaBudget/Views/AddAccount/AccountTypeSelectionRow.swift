import SwiftUI

struct AccountTypeSelectionRow: View {
    @Binding var selectedAccountType: AccountType
    @Binding var selectedIcon: String
    
    var body: some View {
        Menu {
            ForEach(AccountType.allCases, id: \.self) { type in
                Button {
                    selectedAccountType = type
                    selectedIcon = type.iconName
                } label: {
                    HStack {
                        Image(type.iconName)
                        Text(type.displayName)
                    }
                }
            }
        } label: {
            HStack {
                Image(selectedAccountType.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.primary)
                
                Text("type".localized)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(selectedAccountType.displayName)
                    .foregroundStyle(.secondary)
                
                Image("chevron.up.down")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, 4)
            }
            .contentShape(Rectangle())
        }
    }
}
