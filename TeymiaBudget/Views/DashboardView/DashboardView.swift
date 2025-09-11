import SwiftUI
import SwiftData

struct DashboardView: View {
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
                .navigationTitle("Overview")
                .navigationBarTitleDisplayMode(.large)
            }
            
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
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
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
            VStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                
                Text("Add your first account")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    )
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

// MARK: - Account Carousel
struct AccountCarouselView: View {
    let accounts: [Account]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                    AccountCardView(account: account)
                        .padding(.horizontal, 30)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 140)
            
            if accounts.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<accounts.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? .accent : .accent.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Account Card
struct AccountCardView: View {
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(account.type.iconName) 
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(account.type.color.gradient)
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(account.formattedBalance)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.separator, lineWidth: 0.15)
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
}

// MARK: - Extensions
extension AccountType {
    var iconName: String {
        switch self {
        case .cash: return "cash"
        case .bankAccount: return "bank"
        case .creditCard: return "credit_card"
        case .savings: return "savings"
        }
    }
    
    var color: Color {
        switch self {
        case .cash: return .green
        case .bankAccount: return .blue
        case .creditCard: return .orange
        case .savings: return .purple
        }
    }
    
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .bankAccount: return "Bank"
        case .creditCard: return "Card"
        case .savings: return "Savings"
        }
    }
}

extension Account {
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: balance as NSDecimalNumber) ?? "\(currency.symbol)0.00"
    }
}
