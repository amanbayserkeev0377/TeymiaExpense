import SwiftUI
import SwiftData

struct BalanceView: View {
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
    @State private var selectedAccountTransactions: Account?
    
    @Namespace private var balanceNamespace
    
    var baseCurrency: Currency {
        userPreferences.baseCurrency
    }
    
    private var totalBalanceInBaseCurrency: Decimal {
        accounts.reduce(0) { total, account in
            total + CurrencyService.shared.convert(account.balance, from: account.currencyCode, to: baseCurrency.code)
        }
    }
    
    var body: some View {
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
                    ForEach(accounts) { account in
                        AccountRowView(account: account)
                            .matchedTransitionSource(id: account.id, in: balanceNamespace)
                            .onTapGesture {
                                if isEditMode {
                                    editingAccount = account
                                } else {
                                    selectedAccountTransactions = account
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    confirmDeleteAccount(account)
                                } label: {
                                    Image("trash.swipe")
                                }
                                .tint(.red)
                                
                                Button {
                                    editingAccount = account
                                } label: {
                                    Image("pencil.swipe")
                                }
                                .tint(.gray)
                            }
                    }
                    .onMove(perform: moveAccounts)
                    .onDelete(perform: deleteAccountsFromEditMode)
                } header: {
                    HStack {
                        Text("total".localized + ":")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(CurrencyFormatter.format(totalBalanceInBaseCurrency, currency: baseCurrency))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .refreshable {
            await CurrencyService.shared.refreshRates(for: accounts, baseCurrencyCode: "USD")
            withAnimation {
                lastRatesUpdate = Date()
            }
        }
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("balance".localized)
        .toolbar {
            EditDoneToolbarButton(isEditMode: $isEditMode, action: nil)
            AddToolbarButton { showingAddAccount = true }
        }
        .task {
            await CurrencyService.shared.refreshRatesIfNeeded(for: accounts, baseCurrencyCode: "USD")
            withAnimation {
                lastRatesUpdate = Date()
            }
        }
        .sheet(item: $selectedAccountTransactions) { account in
            AccountTransactionsView(account: account)
                .navigationTransition(.zoom(sourceID: account.id, in: balanceNamespace))
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
        var ArrayForSorting = accounts.map { $0 }
        ArrayForSorting.move(fromOffsets: source, toOffset: destination)
        
        for index in 0..<ArrayForSorting.count {
            ArrayForSorting[index].sortOrder = index
        }
    }
    
    private func deleteAccountsFromEditMode(at offsets: IndexSet) {
        for index in offsets {
            let account = accounts[index]
            confirmDeleteAccount(account)
        }
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
            AccountIconView(
                iconName: account.customIcon,
                color: account.actualColor,
                size: 16
            )
            
            Text(account.name)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(account.formattedBalance)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}
