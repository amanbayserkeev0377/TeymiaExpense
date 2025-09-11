import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var accounts: [Account]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var showingAddTransaction = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Account Cards Section (horizontal scroll)
                        accountCardsSection
                        
                        // Transaction List
                        transactionsSection
                        
                        Spacer(minLength: 120) // Space for FAB + tab bar
                    }
                    .padding(.top, 8)
                }
                .navigationTitle("Overview")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    createSampleDataIfNeeded()
                }
            }
            
            // Floating Action Button
            FloatingAddButton {
                showingAddTransaction = true
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                .presentationDetents([.fraction(0.99)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
    }
    
    // MARK: - Account Cards Section
    private var accountCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Accounts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                
                Spacer()
                
                Button {
                    // TODO: Add account action
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.accent)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 20)
            }
            
            if accounts.isEmpty {
                emptyAccountsView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(accounts) { account in
                            AccountCardView(account: account)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Transactions Section
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Transactions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !transactions.isEmpty {
                    NavigationLink("See All") {
                        TransactionHistoryView()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            if transactions.isEmpty {
                emptyTransactionsView
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(transaction: transaction)
                        
                        if index < transactions.count - 1 {
                            Divider()
                                .padding(.leading, 76) // Account for icon + padding
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground).opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.separator, lineWidth: 0.15)
                        )
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Empty States
    private var emptyAccountsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wallet.bifold")
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
            
            Text("Add your first account")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.separator, lineWidth: 0.15)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet")
                .foregroundColor(.secondary)
                .frame(width: 48, height: 48)
            
            VStack(spacing: 6) {
                Text("No transactions yet")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap the + button to add your first transaction")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.separator, lineWidth: 0.15)
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    private func createSampleDataIfNeeded() {
        // Create sample data if needed - implement this later
        guard accounts.isEmpty && transactions.isEmpty else { return }
        
        // TODO: Add sample data creation logic here when models are ready
    }
}

// MARK: - Account Card View
struct AccountCardView: View {
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and type
            HStack {
                Image(systemName: sfSymbolForAccountType(account.type))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(colorForAccountType(account.type).gradient)
                    )
                
                Spacer()
                
                Text(account.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.secondary.opacity(0.1))
                    )
            }
            
            Spacer()
            
            // Account info
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(formatCurrency(account.balance, currency: account.currency))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)
            }
        }
        .padding(20)
        .frame(width: 200, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.separator, lineWidth: 0.15)
                )
        )
    }
    
    private func sfSymbolForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bankAccount: return "building.columns"
        case .creditCard: return "creditcard"
        case .savings: return "piggybank"
        }
    }
    
    private func colorForAccountType(_ type: AccountType) -> Color {
        switch type {
        case .cash: return .green
        case .bankAccount: return .blue
        case .creditCard: return .orange
        case .savings: return .purple
        }
    }
    
    private func formatCurrency(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency.symbol)0.00"
    }
}
