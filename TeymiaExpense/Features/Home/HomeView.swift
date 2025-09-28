import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    @Query private var accounts: [Account]
    @Query(
        filter: #Predicate<Transaction> { !$0.isHidden },
        sort: \Transaction.date,
        order: .reverse
    ) private var allTransactions: [Transaction]
    @StateObject private var firstLaunchManager = FirstLaunchManager()
    
    @State private var showingAccountsManagement = false
    @State private var editingTransaction: Transaction?
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    // View Properties
    @State private var topInset: CGFloat = 0
    @State private var scrollOffsetY: CGFloat = 0
    @State private var scrollProgressX: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 15) {
                    // Accounts Carousel
                    AccountsCarouselView(
                        accounts: accounts,
                        scrollProgressX: $scrollProgressX,
                        topInset: topInset,
                        scrollOffsetY: scrollOffsetY
                    )
                    .zIndex(-1)
                    
                    // Transactions Section
                    TransactionsListView(
                        transactions: filteredTransactions,
                        startDate: $startDate,
                        endDate: $endDate,
                        userPreferences: userPreferences,
                        currencies: currencies,
                        onEditTransaction: { transaction in
                            editingTransaction = transaction
                        },
                        onHideTransaction: hideTransaction,
                        onDeleteTransaction: deleteTransaction
                    )
                    .padding(.top, 20)
                }
            }
            .safeAreaPadding(15)
            .background(Color.mainBackground)
            .onScrollGeometryChange(for: ScrollGeometry.self) {
                $0
            } action: { oldValue, newValue in
                topInset = newValue.contentInsets.top + 100
                scrollOffsetY = newValue.contentOffset.y + newValue.contentInsets.top
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAccountsManagement = true
                    } label: {
                        Image("cards.blank")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAccountsManagement) {
            AccountsManagementView()
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $firstLaunchManager.shouldShowOnboarding) {
            OnboardingView(onComplete: {
                firstLaunchManager.completeOnboarding()
            })
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return allTransactions.filter { transaction in
            transaction.date >= startOfStartDate && transaction.date < endOfEndDate
        }
    }
    
    // MARK: - Transaction Actions
    
    private func hideTransaction(_ transaction: Transaction) {
        withAnimation(.snappy) {
            transaction.isHidden = true
            try? modelContext.save()
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.snappy) {
            TransactionService.revertBalanceChanges(for: transaction)
            modelContext.delete(transaction)
            try? modelContext.save()
        }
    }
}
