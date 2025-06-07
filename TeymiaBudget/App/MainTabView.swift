//
//  MainTabView.swift
//  TeymiaBudget
//
//  Main tab navigation with floating action button
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingActionSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Home tab
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                // Analytics tab
                AnalyticsView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Analytics")
                    }
                    .tag(1)
                
                // Placeholder for center button
                Color.clear
                    .tabItem {
                        Image(systemName: "")
                        Text("")
                    }
                    .tag(2)
                
                // Budgets tab
                BudgetsView()
                    .tabItem {
                        Image(systemName: "target")
                        Text("Budgets")
                    }
                    .tag(3)
                
                // Settings tab
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(4)
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {
                        showingActionSheet = true
                    } label: {
                        Image(systemName: "arrow.down.left.arrow.up.right")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(.blue.gradient)
                                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .offset(y: -25) // Поднимаем над tab bar
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingActionSheet) {
            QuickActionSheet()
                .presentationDetents([.fraction(0.35), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Quick Action Sheet
struct QuickActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Handle indicator (опционально, уже есть системный)
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 6)
                .foregroundColor(.secondary.opacity(0.3))
                .padding(.top, 8)
            
            Text("Add Transaction")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            // Action buttons
            HStack(spacing: 32) {
                QuickActionButton(
                    title: "Income",
                    icon: "arrow.down.circle.fill",
                    color: .green
                ) {
                    // Handle income action
                    dismiss()
                }
                
                QuickActionButton(
                    title: "Expense",
                    icon: "arrow.up.circle.fill",
                    color: .red
                ) {
                    // Handle expense action
                    dismiss()
                }
                
                QuickActionButton(
                    title: "Scan",
                    icon: "camera.circle.fill",
                    color: .blue
                ) {
                    // Handle scan action
                    dismiss()
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(color.gradient)
                            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                    )
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Placeholder Views
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Total Balance Section
                    totalBalanceSection
                    
                    // Account Cards Section
                    accountCardsSection
                    
                    // Recent Transactions Section
                    recentTransactionsSection
                    
                    Spacer(minLength: 80) // Space for floating button
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Teymia Budget")
            .onAppear {
                createSampleDataIfNeeded()
            }
        }
    }
    
    // MARK: - Total Balance
    private var totalBalanceSection: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(totalBalance))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Account Cards
    private var accountCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Add") {
                    // TODO: Add account action
                }
                .font(.subheadline)
                .foregroundColor(.blue)
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
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    // MARK: - Recent Transactions
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("See All") {
                    // TODO: Show all transactions
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if recentTransactions.isEmpty {
                emptyTransactionsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty States
    private var emptyAccountsView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.1))
            .frame(height: 120)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "creditcard")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No accounts yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )
    }
    
    private var emptyTransactionsView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.1))
            .frame(height: 80)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "list.bullet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("No transactions yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
    
    // MARK: - Computed Properties
    private var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    private var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(5))
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // TODO: Use user's default currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
    
    private func createSampleDataIfNeeded() {
        // Create sample data only if no accounts exist
        guard accounts.isEmpty else { return }
        
        // Create default currency
        let usd = Currency(code: "USD", symbol: "$", name: "US Dollar", isDefault: true)
        modelContext.insert(usd)
        
        // Create sample accounts
        let cashAccount = Account(
            name: "Cash",
            type: .cash,
            balance: 1250.50,
            currency: usd,
            isDefault: true
        )
        
        let bankAccount = Account(
            name: "Chase Checking",
            type: .bankAccount,
            balance: 5420.75,
            currency: usd
        )
        
        modelContext.insert(cashAccount)
        modelContext.insert(bankAccount)
        
        // Create sample categories
        let foodCategory = Category(
            name: "Food & Dining",
            iconName: "fork.knife",
            colorHex: "#FF6B6B",
            type: .expense,
            isDefault: true
        )
        
        let salaryCategory = Category(
            name: "Salary",
            iconName: "banknote",
            colorHex: "#4ECDC4",
            type: .income,
            isDefault: true
        )
        
        modelContext.insert(foodCategory)
        modelContext.insert(salaryCategory)
        
        // Create sample transactions
        let transaction1 = Transaction(
            amount: -45.50,
            note: "Lunch at cafe",
            date: Date().addingTimeInterval(-3600), // 1 hour ago
            type: .expense,
            category: foodCategory,
            account: cashAccount
        )
        
        let transaction2 = Transaction(
            amount: 3500.00,
            note: "Monthly salary",
            date: Date().addingTimeInterval(-86400), // 1 day ago
            type: .income,
            category: salaryCategory,
            account: bankAccount
        )
        
        modelContext.insert(transaction1)
        modelContext.insert(transaction2)
        
        try? modelContext.save()
    }
}

// MARK: - Account Card View
struct AccountCardView: View {
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Account icon
                Image(systemName: iconForAccountType(account.type))
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(colorForAccountType(account.type))
                    )
                
                Spacer()
                
                // Account type
                Text(account.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.gray.opacity(0.1))
                    )
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatCurrency(account.balance, currency: account.currency))
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding(16)
        .frame(width: 200, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bankAccount: return "building.columns"
        case .creditCard: return "creditcard"
        case .savings: return "bag"
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

// MARK: - Transaction Row View
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            if let category = transaction.category {
                Image(systemName: category.iconName)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(hex: category.colorHex) ?? .gray)
                    )
            } else {
                Image(systemName: "questionmark")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.gray)
                    )
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(RelativeDateTimeFormatter().localizedString(for: transaction.date, relativeTo: Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(formatTransactionAmount(transaction.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTransactionAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let formattedAmount = formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
        
        if amount >= 0 {
            return "+\(formattedAmount)"
        } else {
            return formattedAmount
        }
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AnalyticsView: View {
    var body: some View {
        NavigationView {
            Text("Analytics - Charts & Reports")
                .navigationTitle("Analytics")
        }
    }
}

struct BudgetsView: View {
    var body: some View {
        NavigationView {
            Text("Budgets - Budget Progress & Limits")
                .navigationTitle("Budgets")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings - App Configuration")
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    MainTabView()
}
