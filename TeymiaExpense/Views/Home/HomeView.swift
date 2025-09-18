import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var accounts: [Account]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var showingAddTransaction = false
    @State private var showingAddAccount = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Account Cards Carousel
                        accountCardsSection
                        
                        // Transaction List
                        transactionsSection
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.top, 8)
                }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.large)
            }
            
            FloatingAddButton {
                showingAddTransaction = true
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .presentationDragIndicator(.visible)
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
                    showingAddAccount = true
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
                AccountCarouselView(accounts: accounts)
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
                                .padding(.leading, 76)
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
        Button {
            showingAddAccount = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.blue)
                    .font(.system(size: 48))
                
                VStack(spacing: 8) {
                    Text("Add your first account")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("Create a bank account, cash wallet, or credit card")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                    )
                    .foregroundStyle(.blue.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    
    private var emptyTransactionsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.dashed")
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
}
