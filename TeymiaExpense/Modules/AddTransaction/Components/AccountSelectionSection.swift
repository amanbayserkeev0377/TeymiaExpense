import SwiftUI

struct AccountSelectionSection: View {
    @Binding var selectedAccount: Account?
    let accounts: [Account]
    
    var body: some View {
        Section("account".localized) {
            ForEach(accounts) { account in
                Button {
                    selectedAccount = account
                } label: {
                    HStack {
                        Image(account.cardIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(selectedAccount == account ? .primary : .secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .foregroundStyle(.primary)
                            
                            Text(account.formattedBalance)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedAccount == account {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.app)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listRowBackground(Color.mainRowBackground)
    }
}
