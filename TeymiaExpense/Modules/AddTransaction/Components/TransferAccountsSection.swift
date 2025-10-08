import SwiftUI

struct TransferAccountsSection: View {
    @Binding var fromAccount: Account?
    @Binding var toAccount: Account?
    let accounts: [Account]
    let onAddAccountTapped: () -> Void
    
    var body: some View {
        Section("from_account".localized) {
            ForEach(accounts) { account in
                Button {
                    fromAccount = account
                    if toAccount == account {
                        toAccount = nil
                    }
                } label: {
                    HStack {
                        Image(account.cardIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(fromAccount == account ? .primary : .secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .foregroundStyle(.primary)
                            
                            Text(account.formattedBalance)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if fromAccount == account {
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
        
        Section("to_account".localized) {
            let availableToAccounts = accounts.filter { $0 != fromAccount }
            
            if availableToAccounts.isEmpty {
                Button {
                    onAddAccountTapped()
                } label: {
                    Label("Add another account for transfers", systemImage: "plus")
                        .foregroundStyle(.app)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            } else {
                ForEach(availableToAccounts) { account in
                    Button {
                        toAccount = account
                    } label: {
                        HStack {
                            Image(account.cardIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(toAccount == account ? .primary : .secondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.name)
                                    .foregroundStyle(.primary)
                                
                                Text(account.formattedBalance)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if toAccount == account {
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
        }
        .listRowBackground(Color.mainRowBackground)
    }
}
