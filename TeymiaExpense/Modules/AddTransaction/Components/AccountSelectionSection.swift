import SwiftUI

struct AccountSelectionSection: View {
    @Binding var selectedAccount: Account?
    let accounts: [Account]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Section("account".localized) {
            if accounts.isEmpty {
                ContentUnavailableView(
                    "No accounts",
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
        }
        .listRowBackground(Color.mainRowBackground)
        .listRowInsets(EdgeInsets())
    }
    
    private func accountButton(account: Account) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAccount = account
            }
        } label: {
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
                        selectedAccount == account
                        ? (colorScheme == .light ? Color.white : Color.black)
                        : Color.primary
                    )
                    .padding(10)
                    .background(
                        Circle()
                            .fill(
                                selectedAccount == account
                                ? Color.primary
                                : Color.secondary.opacity(0.1)
                            )
                    )
                
                // Баланс
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
