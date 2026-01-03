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
                    LazyHStack(spacing: 16) {
                        ForEach(accounts) { account in
                            accountButton(account: account)
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
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listSectionSpacing(0)
    }
    
    private func accountButton(account: Account) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAccount = account
            }
        } label: {
            VStack(spacing: 6) {
                Image(account.cardIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(
                        selectedAccount == account
                        ? Color.primaryInverse
                        : Color.primary
                    )
                    .padding(10)
                    .background(
                        Circle()
                            .fill(
                                selectedAccount == account
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
                
                // Баланс
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
