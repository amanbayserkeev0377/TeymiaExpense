import SwiftUI
import SwiftData

struct HomeView: View {
    @Namespace private var animation
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    @Query private var accounts: [Account]
    @Query(
        filter: #Predicate<Transaction> { !$0.isHidden },
        sort: \Transaction.date,
        order: .reverse
    ) private var allTransactions: [Transaction]
    @StateObject private var firstLaunchManager = FirstLaunchManager()
    
    @State private var showingAddAccount = false
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
                    HeaderView()
                    
                    CarouselView()
                        .zIndex(-1)
                    
                    // Transactions Section
                    TransactionsSection()
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
                        showingAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $firstLaunchManager.shouldShowOnboarding) {
            DrawOnSymbolEffectExample(
                tint: AccountColors.color(at: 0),
                buttonTitle: "Start Managing Money",
                data: [
                    .init(
                        name: "chart.bar.xaxis.ascending",
                        title: "Categorized Expenses",
                        subtitle: "Categorize your expenses to see\n where your money is going",
                        preDelay: 0.3
                    ),
                    .init(
                        name: "magnifyingglass.circle",
                        title: "Search for Expenses",
                        subtitle: "Search for your expenses\nby account or category",
                        preDelay: 1.6
                    ),
                    .init(
                        name: "arrow.up.arrow.down",
                        title: "Track Your Money",
                        subtitle: "Easily manage your income\nand expenses in one place",
                        preDelay: 1.2
                    ),
                ]
            ) {
                firstLaunchManager.completeOnboarding()
            }
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    func HeaderView() -> some View {
        HStack {
            Spacer(minLength: 0)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Carousel View
    @ViewBuilder
    func CarouselView() -> some View {
        let spacing: CGFloat = 6
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: spacing) {
                ForEach(accounts) { account in
                    AccountCardView(account: account)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: 220)
        .background(BackdropEffect())
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .onScrollGeometryChange(for: CGFloat.self) {
            let offsetX = $0.contentOffset.x + $0.contentInsets.leading
            let width = $0.containerSize.width + spacing
            
            return offsetX / width
        } action: { oldValue, newValue in
            let maxValue = CGFloat(max(accounts.count - 1, 0))
            scrollProgressX = min(max(newValue, 0), maxValue)
        }
    }
    
    // MARK: - Transactions Section
    @ViewBuilder
    func TransactionsSection() -> some View {
        VStack(spacing: 16) {
            // Section Header with Filter
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transaction History")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
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
            
            // Transactions List
            if filteredTransactions.isEmpty {
                EmptyTransactionsView()
            } else {
                TransactionsList()
            }
        }
    }
    
    // MARK: - Transactions List
    @ViewBuilder
    func TransactionsList() -> some View {
        let groupedTransactions = Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        let sortedDates = groupedTransactions.keys.sorted(by: >)
        
        LazyVStack(spacing: 20) {
            ForEach(sortedDates, id: \.self) { date in
                VStack(spacing: 12) {
                    // Date Header
                    HStack {
                        Text(formatDateHeader(date))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if let dayTransactions = groupedTransactions[date] {
                            let dayTotal = dayTransactions.reduce(Decimal.zero) { $0 + $1.amount }
                            Text(formatAmount(dayTotal))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(dayTotal >= 0 ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Transactions for this date
                    if let dayTransactions = groupedTransactions[date] {
                        LazyVStack(spacing: 8) {
                            ForEach(dayTransactions) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .glassEffect(.regular.interactive().tint(.mainRowBackground), in: RoundedRectangle(cornerRadius: 24))
                                    .swipeActions {
                                        Action(
                                            imageName: "eye.crossed",
                                            tint: .white,
                                            background: .gray,
                                            size: .init(width: 50, height: 50)
                                        ) { resetPosition in
                                            hideTransaction(transaction)
                                            resetPosition.toggle()
                                        }
                                        
                                        Action(
                                            imageName: "trash",
                                            tint: .white,
                                            background: .red,
                                            size: .init(width: 50, height: 50)
                                        ) { resetPosition in
                                            deleteTransaction(transaction)
                                            resetPosition.toggle()
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Backdrop Effect
    @ViewBuilder
    func BackdropEffect() -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(accounts.reversed()) { account in
                    let index = CGFloat(accounts.firstIndex(where: { $0.id == account.id }) ?? 0) + 1
                    
                    switch account.designType {
                    case .image:
                        Image(account.cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                            .opacity(index - scrollProgressX)
                        
                    case .color:
                        Rectangle()
                            .fill(AccountColors.gradient(at: account.designIndex))
                            .frame(width: size.width, height: size.height)
                            .opacity(index - scrollProgressX)
                    }
                }
            }
            .compositingGroup()
            .blur(radius: 25, opaque: true)
            .overlay {
                Rectangle()
                    .fill(.black.opacity(0.25))
            }
            .mask {
                Rectangle()
                    .fill(.linearGradient(colors: [
                        .black,
                        .black.opacity(0.7),
                        .black.opacity(0.6),
                        .black.opacity(0.3),
                        .black.opacity(0.25),
                        .clear
                    ], startPoint: .top, endPoint: .bottom))
            }
        }
        .containerRelativeFrame(.horizontal)
        .padding(.bottom, -60)
        .padding(.top, -topInset)
        .offset(y: scrollOffsetY < 0 ? scrollOffsetY : 0)
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
    
    private var dateRangeText: String {
        DateFormatter.formatDateRange(startDate: startDate, endDate: endDate)
    }
    
    // MARK: - Helper Methods
    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        return userPreferences.formatAmount(amount, currencies: currencies)
    }
    
    // MARK: - Swipe Actions Helper Methods
    private func hideTransaction(_ transaction: Transaction) {
        withAnimation(.snappy) {
            transaction.isHidden = true
            try? modelContext.save()
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.snappy) {
            // Update account balance
            if let account = transaction.account {
                account.balance -= transaction.amount
            }
            
            // Delete transaction
            modelContext.delete(transaction)
            
            try? modelContext.save()
        }
    }
}

// MARK: - Supporting Views

struct EmptyTransactionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("list.empty")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.secondary)
            
            Text("No transactions found for the selected period")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
    }
}
