import SwiftUI
import SwiftData

struct BalanceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    
    @State private var showingAddAccount = false
    @State private var editingAccount: Account?
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    @State private var isEditMode = false
    @State private var lastRatesUpdate: Date = Date()
    
    var baseCurrency: Currency {
            userPreferences.baseCurrency
        }
        
    private var totalBalanceInBaseCurrency: Decimal {
        accounts.reduce(0) { total, account in
            total + CurrencyService.shared.convert(account.balance, from: account.currencyCode, to: baseCurrency.code)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if accounts.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "no_accounts".localized,
                            systemImage: "magnifyingglass",
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
                        HStack {
                            Text("total".localized + ":")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(CurrencyFormatter.format(totalBalanceInBaseCurrency, currency: baseCurrency))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .refreshable {
                await CurrencyService.shared.refreshRates(for: accounts, baseCurrencyCode: "USD")
                withAnimation {
                    lastRatesUpdate = Date()
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .scrollContentBackground(.hidden)
            .background {
                BackgroundView()
            }
            .navigationTitle("balance".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditDoneToolbarButton(isEditMode: $isEditMode, action: nil)
                
                AddToolbarButton {
                    showingAddAccount = true
                }
            }
        }
        .task {
            await CurrencyService.shared.refreshRatesIfNeeded(for: accounts, baseCurrencyCode: "USD")
            withAnimation {
                lastRatesUpdate = Date()
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
        .sheet(item: $editingAccount) { account in
            AddAccountView(editingAccount: account)
        }
        .alert("", isPresented: $showingDeleteAlert) {
            Button("cancel".localized, role: .cancel) {
                pendingDeleteAction = nil
            }
            Button("delete".localized, role: .destructive) {
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
        deleteAlertMessage = "account_delete_alert".localized
        
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
        .contentShape(Rectangle())
    }
}
