import SwiftUI
import SwiftData

struct BalanceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    
    @State private var showingAddAccount = false
    @State private var editingAccount: Account?
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    @State private var isEditMode = false
    
    var body: some View {
        NavigationStack {
            List {
                if accounts.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "No accounts",
                            systemImage: "magnifyingglass",
                            description: Text("Create your first account to start tracking expenses")
                        )
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(accounts, id: \.id) { account in
                            AccountRowView(account: account)
                                .onTapGesture {
                                    if !isEditMode {
                                        editingAccount = account
                                    }
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        confirmDeleteAccount(account)
                                    } label: {
                                        Image("trash.swipe")
                                    }
                                    .tint(.red)
                                }
                        }
                        .onMove(perform: isEditMode ? moveAccounts : nil)
                    } header: {
                        Text("Total:")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.primary)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .scrollContentBackground(.hidden)
            .background {
                LivelyFloatingBlobsBackground()
            }
            .navigationTitle("Balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditDoneToolbarButton(isEditMode: $isEditMode, action: nil)
                
                AddToolbarButton {
                    showingAddAccount = true
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
        .sheet(item: $editingAccount) { account in
            AddAccountView(editingAccount: account)
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                pendingDeleteAction = nil
            }
            Button("Delete", role: .destructive) {
                pendingDeleteAction?()
                pendingDeleteAction = nil
            }
        } message: {
            Text(deleteAlertMessage)
        }
    }
    
    // MARK: - Helper Methods
    
    private func moveAccounts(from source: IndexSet, to destination: Int) {
        var accountsArray = accounts
        accountsArray.move(fromOffsets: source, toOffset: destination)
        
        // Update sortOrder for all accounts
        for (index, account) in accountsArray.enumerated() {
            account.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    private func confirmDeleteAccount(_ account: Account) {
        let transactionCount = account.transactions?.count ?? 0
        
        if transactionCount > 0 {
            deleteAlertMessage = "This account has \(transactionCount) transactions. Deleting it will also delete all associated transactions."
        } else {
            deleteAlertMessage = "This will delete the account."
        }
        
        pendingDeleteAction = {
            withAnimation {
                modelContext.delete(account)
                try? modelContext.save()
            }
        }
        showingDeleteAlert = true
    }
}

// MARK: - Account Row View

struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack(spacing: 12) {
            // Account icon or design preview
            Group {
                if account.designType == .image {
                    if account.designIndex == -1, let customImage = account.customUIImage {
                        Image(uiImage: customImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(AccountImageData.image(at: account.designIndex).imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } else if account.designType == .color {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AccountColor.gradient(at: account.designIndex))
                        .frame(width: 50, height: 32)
                }
            }
            
            HStack {
                Text(account.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text(account.formattedBalance)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
