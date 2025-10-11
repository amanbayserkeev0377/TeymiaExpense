import SwiftUI
import SwiftData

struct AccountsManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    
    @State private var showingAddAccount = false
    @State private var editingAccount: Account?
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            List {
                if accounts.isEmpty {
                    Section {
                        EmptyAccountsView()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(accounts, id: \.id) { account in
                            AccountRowView(account: account)
                                .onTapGesture {
                                    editingAccount = account
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        confirmDeleteAccount(account)
                                    } label: {
                                        Image("trash.swipe")
                                    }
                                    .tint(.red)
                                    Button {
                                        editingAccount = account
                                    } label: {
                                        Image("edit")
                                    }
                                    .tint(.blue)
                                }
                        }
                    } footer: {
                        Text("Tap to edit or swipe left for more options.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.mainRowBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground)
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingAccount) { account in
            AddAccountView(editingAccount: account)
                .presentationDragIndicator(.visible)
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
    
    private func confirmDeleteAccount(_ account: Account) {
        let transactionCount = account.transactions?.count ?? 0
        
        if transactionCount > 0 {
            deleteAlertMessage = "This account has \(transactionCount) transactions. Deleting it will also delete all associated transactions."
        } else {
            deleteAlertMessage = "This will delete the account."
        }
        
        pendingDeleteAction = {
            withAnimation {
                // Note: SwiftData cascade delete will handle transactions automatically
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
                    Image(account.cardImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AccountColors.gradient(at: account.designIndex))
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
    }
}

// MARK: - Empty State View

struct EmptyAccountsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("wallet")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Accounts")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("Create your first account to start tracking expenses")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
