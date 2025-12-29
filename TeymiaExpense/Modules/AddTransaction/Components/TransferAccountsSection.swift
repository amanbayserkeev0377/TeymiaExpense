import SwiftUI

struct TransferAccountsSection: View {
    @Binding var fromAccount: Account?
    @Binding var toAccount: Account?
    let accounts: [Account]
    let onAddAccountTapped: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Section("transfer_from".localized) {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "no_accounts".localized,
                    systemImage: "magnifyingglass"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(accounts) { account in
                            accountButton(
                                account: account,
                                isSelected: fromAccount == account
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    fromAccount = account
                                    if toAccount == account {
                                        toAccount = nil
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        
        Section("transfer_to".localized) {
            let availableToAccounts = accounts.filter { $0 != fromAccount }
            
            if availableToAccounts.isEmpty {
                ContentUnavailableView(
                    accounts.isEmpty ? "no_accounts".localized : "create_second_account".localized,
                    systemImage: "arrow.2.circlepath",
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(availableToAccounts) { account in
                            accountButton(
                                account: account,
                                isSelected: toAccount == account
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    toAccount = account
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
            }
        }
        .listRowInsets(EdgeInsets())
    }
    
    private func accountButton(
        account: Account,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(account.name)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Image(account.cardIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(
                        isSelected
                        ? (colorScheme == .light ? Color.white : Color.black)
                        : Color.primary
                    )
                    .padding(10)
                    .background(
                        Circle()
                            .fill(
                                isSelected
                                ? Color.primary
                                : Color.secondary.opacity(0.1)
                            )
                    )
                
                Text(account.formattedBalance)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
