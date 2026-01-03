import SwiftUI

struct TransferAccountsSection: View {
    @Binding var fromAccount: Account?
    @Binding var toAccount: Account?
    let accounts: [Account]
    let onAddAccountTapped: () -> Void
    
    var body: some View {
        Section {
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
        } header: {
            Text("transfer_from".localized)
                .padding(.leading, 16)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        
        Section {
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
        } header: {
            Text("transfer_to".localized)
                .padding(.leading, 16)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    private func accountButton(
        account: Account,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(account.cardIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(
                        isSelected
                        ? Color.primaryInverse
                        : Color.primary
                    )
                    .padding(10)
                    .background(
                        Circle()
                            .fill(
                                isSelected
                                ? Color.primary
                                : Color.secondary.opacity(0.07)
                            )
                    )
                
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
