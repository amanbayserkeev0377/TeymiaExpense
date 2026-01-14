import SwiftUI

struct AccountSelectionSection: View {
    @Binding var selectedAccount: Account?
    let accounts: [Account]
    
    var body: some View {
        Section {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "no_accounts".localized,
                    systemImage: "magnifyingglass"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(accounts) { account in
                            accountButton(
                                account: account,
                                isSelected: selectedAccount?.id == account.id
                            )
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
            }
        } header: {
            Text("account".localized)
                .padding(.leading, 16)
        }
        .listRowInsets(EdgeInsets())
    }
    
    private func accountButton(account: Account, isSelected: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAccount = account
            }
        } label: {
            VStack(spacing: 6) {
                AccountIconView(
                    iconName: account.customIcon,
                    color: account.actualColor
                )
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.secondary, lineWidth: 2)
                    }
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(account.name)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(account.formattedBalance)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
