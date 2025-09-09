import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var showingAddTransaction = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Balance Section
                        balanceSection
                        
                        // Today's Summary
                        todaySection
                        
                        // Recent Transactions
                        recentTransactionsSection
                        
                        Spacer(minLength: 120) // Space for FAB + tab bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .navigationTitle("Teymia Budget")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    createSampleDataIfNeeded()
                }
            }
            
            // Floating Action Button
            Button {
                showingAddTransaction = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image("icon_add")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 120) // Above tab bar
        }
        .fullScreenCover(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
    
    // MARK: - Balance Section
    private var balanceSection: some View {
        VStack(spacing: 8) {
            Text("Current Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(totalBalance))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(totalBalance >= 0 ? .primary : .red)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Today Section
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                // Income
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image("icon_income")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.green)
                            .frame(width: 16, height: 16)
                        
                        Text("Income")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(formatCurrency(todayIncome))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Expenses
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("Expenses")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Image("icon_expense")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.red)
                            .frame(width: 16, height: 16)
                    }
                    
                    Text(formatCurrency(todayExpenses))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Recent Transactions
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !recentTransactions.isEmpty {
                    NavigationLink("See All") {
                        TransactionHistoryView()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if recentTransactions.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(transaction: transaction)
                        
                        if index < recentTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image("icon_empty_wallet")
                .resizable()
                .renderingMode(.template)
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
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Computed Properties
    private var totalBalance: Decimal {
        transactions.reduce(0) { total, transaction in
            transaction.type == .expense ? total - transaction.amount.magnitude : total + transaction.amount
        }
    }
    
    private var todayTransactions: [Transaction] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return transactions.filter { transaction in
            transaction.date >= today && transaction.date < tomorrow
        }
    }
    
    private var todayIncome: Decimal {
        todayTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var todayExpenses: Decimal {
        todayTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount.magnitude }
    }
    
    private var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
    
    private func createSampleDataIfNeeded() {
        // Create sample data if needed - implement this later
        guard transactions.isEmpty else { return }
        
        // TODO: Add sample data creation logic here when models are ready
    }
}

#Preview {
    HomeView()
}
