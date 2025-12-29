import SwiftUI
import SwiftData

struct HomeView: View {
    @Namespace private var animation
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    @Query(sort: \Transaction.date, order: .reverse)
    private var allTransactions: [Transaction]
    
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    // View Properties
    @State private var topInset: CGFloat = 0
    @State private var scrollOffsetY: CGFloat = 0
    @State private var scrollProgressX: CGFloat = 0
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    private var dateRangeText: String {
        DateFormatter.formatDateRange(startDate: startDate, endDate: endDate)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let safeArea = geometry.safeAreaInsets
                
                ZStack {
                    List {
                        // Accounts Carousel Section
                        Section {
                            AccountsCarouselView(
                                accounts: accounts,
                                scrollProgressX: $scrollProgressX,
                                topInset: topInset,
                                scrollOffsetY: scrollOffsetY
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .padding(.top, 100)
                        
                        // Transactions Header
                        Section {
                            HStack {
                                Text(dateRangeText)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                // Date Filter Menu
                                CustomMenuView(style: .glass) {
                                    Image("calendar")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .frame(width: 40, height: 30)
                                } content: {
                                    DateFilterView(
                                        startDate: $startDate,
                                        endDate: $endDate
                                    )
                                }
                            }
                            .padding(.top, 10)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .listSectionSpacing(16)
                        
                        // Transactions List
                        if filteredTransactions.isEmpty {
                            Section {
                                ContentUnavailableView(
                                    "no_transactions".localized,
                                    systemImage: "magnifyingglass"
                                )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        } else {
                            ForEach(sortedDates, id: \.self) { date in
                                Section {
                                    ForEach(groupedTransactions[date] ?? []) { transaction in
                                        TransactionRowView(transaction: transaction)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    deleteTransaction(transaction)
                                                } label: {
                                                    Label("", image: "trash.swipe")
                                                }
                                                .tint(.red)
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                editingTransaction = transaction
                                            }
                                    }
                                } header: {
                                    DaySectionHeader(
                                        date: date,
                                        transactions: groupedTransactions[date] ?? [],
                                        userPreferences: userPreferences,
                                        currencies: currencies
                                    )
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background {
                        LivelyFloatingBlobsBackground()
                    }
                    .onScrollGeometryChange(for: ScrollGeometry.self) {
                        $0
                    } action: { oldValue, newValue in
                        topInset = newValue.contentInsets.top + 100
                        scrollOffsetY = newValue.contentOffset.y + newValue.contentInsets.top
                    }
                    
                    FloatingPlusButton(
                        action: { showingAddTransaction = true }
                    )
                }
                .padding(.top, safeArea.top)
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
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
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.snappy) {
            TransactionService.revertBalanceChanges(for: transaction)
            modelContext.delete(transaction)
            try? modelContext.save()
        }
    }
}

// MARK: - Day Section Header

struct DaySectionHeader: View {
    let date: Date
    let transactions: [Transaction]
    let userPreferences: UserPreferences
    let currencies: [Currency]
    
    private var dayTotal: Decimal {
        transactions.reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var dateHeaderText: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "today".localized
        } else if calendar.isDateInYesterday(date) {
            return "yesterday".localized
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack {
            Text(dateHeaderText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(userPreferences.formatAmount(dayTotal, currencies: currencies))
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(dayTotal >= 0 ? Color("IncomeColor") : Color("ExpenseColor"))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .textCase(nil)
    }
}
