import SwiftUI
import SwiftData

struct HomeView: View {
    @Namespace private var animation
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    @Query(
        filter: #Predicate<Transaction> { !$0.isHidden },
        sort: \Transaction.date,
        order: .reverse
    ) private var allTransactions: [Transaction]
    
    @State private var showingAccountsManagement = false
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    // View Properties
    @State private var topInset: CGFloat = 0
    @State private var scrollOffsetY: CGFloat = 0
    @State private var scrollProgressX: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let safeArea = geometry.safeAreaInsets
                
                ZStack {
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            // Sticky Header as Section
                            Section {
                                VStack(spacing: 15) {
                                    // Accounts Carousel
                                    AccountsCarouselView(
                                        accounts: accounts,
                                        scrollProgressX: $scrollProgressX,
                                        topInset: topInset,
                                        scrollOffsetY: scrollOffsetY
                                    )
                                    .zIndex(-1)
                                    
                                    // Glass Transactions Section
                                    GlassTransactionsListView(
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
                                    .padding(.horizontal, 15)
                                    .padding(.top, 20)
                                }
                                .padding(.bottom, 15)
                            } header: {
                                // Custom Blur Header
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 8, opaque: false)
                                    .padding([.horizontal, .top], -30)
                                    .overlay(alignment: .bottom) {
                                        HStack {
                                            Spacer()
                                            
                                            Button {
                                                showingAccountsManagement = true
                                            } label: {
                                                Image("cards.blank")
                                                    .resizable()
                                                    .foregroundStyle(.appTint)
                                                    .frame(width: 24, height: 24)
                                                    .frame(width: 44, height: 44)
                                                    .contentShape(Rectangle())
                                            }
                                            .padding(.trailing, 8)
                                        }
                                        .frame(height: 44)
                                        .padding(.bottom, 8)
                                    }
                                    .frame(height: 100 + safeArea.top)
                                    .padding(.top, -safeArea.top)
                            }
                        }
                    }
                    .onScrollGeometryChange(for: ScrollGeometry.self) {
                        $0
                    } action: { oldValue, newValue in
                        topInset = newValue.contentInsets.top + 100
                        scrollOffsetY = newValue.contentOffset.y + newValue.contentInsets.top
                    }
                    .background {
                        LivelyFloatingBlobsBackground()
                    }
                    
                    FloatingPlusButton(
                        action: { showingAddTransaction = true },
                        animation: animation,
                        useZoomTransition: true,
                        bottomPadding: customTabBarBottomPadding
                    )
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .sheet(isPresented: $showingAccountsManagement) {
            AccountsManagementView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
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
    
    private var customTabBarBottomPadding: CGFloat {
        if #available(iOS 26, *) {
            return 20
        } else {
            return 60
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
