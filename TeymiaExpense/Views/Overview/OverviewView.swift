import SwiftUI
import SwiftData

struct OverviewView: View {
    @Namespace private var animation
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    @Query private var allTransactions: [Transaction]
    
    @State private var selectedCategoryGroup: CategoryGroup?
    
    // Date filtering state
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    // Filtered transactions based on date range
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return allTransactions.filter { transaction in
            !transaction.isHidden &&
            transaction.date >= startOfStartDate &&
            transaction.date < endOfEndDate
        }
    }
    
    // Filter groups that have transactions in selected period
    private var expenseGroupsWithTransactions: [CategoryGroup] {
        categoryGroups
            .filter { $0.type == .expense && hasTransactions(for: $0) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var incomeGroupsWithTransactions: [CategoryGroup] {
        categoryGroups
            .filter { $0.type == .income && hasTransactions(for: $0) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // Calculate totals for the period
    private var totalExpenses: Decimal {
        filteredTransactions
            .filter { $0.type == .expense }
            .reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
    
    private var totalIncome: Decimal {
        filteredTransactions
            .filter { $0.type == .income }
            .reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
    
    private var dateRangeText: String {
        DateFormatter.formatDateRange(startDate: startDate, endDate: endDate)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Date Filter Header
                    HStack {
                        Text(dateRangeText)
                            .font(.title3)
                            .fontWeight(.semibold)
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
                    .padding(.horizontal, 20)
                    
                    // Expenses Section
                    if !expenseGroupsWithTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Expenses")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Text(formatAmount(totalExpenses))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.red)
                            }
                            .padding(.horizontal, 20)
                            
                            Divider()
                            
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                                spacing: 16
                            ) {
                                ForEach(expenseGroupsWithTransactions) { categoryGroup in
                                    Button {
                                        selectedCategoryGroup = categoryGroup
                                    } label: {
                                        categoryGroupButton(categoryGroup: categoryGroup, type: .expense)
                                    }
                                    .matchedTransitionSource(id: "categoryGroup-\(categoryGroup.id)", in: animation)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Income Section
                    if !incomeGroupsWithTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Income")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Text(formatAmount(totalIncome))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                            }
                            .padding(.horizontal, 20)
                            
                            Divider()
                            
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                                spacing: 16
                            ) {
                                ForEach(incomeGroupsWithTransactions) { categoryGroup in
                                    Button {
                                        selectedCategoryGroup = categoryGroup
                                    } label: {
                                        categoryGroupButton(categoryGroup: categoryGroup, type: .income)
                                    }
                                    .matchedTransitionSource(id: "categoryGroup-\(categoryGroup.id)", in: animation)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Empty state when no transactions exist
                    if expenseGroupsWithTransactions.isEmpty && incomeGroupsWithTransactions.isEmpty {
                        EmptyView(isGroups: true)
                            .padding(.top, 60)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.mainBackground)
        }
        .sheet(item: $selectedCategoryGroup) { categoryGroup in
            CategoryGroupOverviewView(
                categoryGroup: categoryGroup,
                filteredTransactions: filteredTransactions
            )
            .navigationTransition(.zoom(sourceID: "categoryGroup-\(categoryGroup.id)", in: animation))
        }
    }
    
    // MARK: - Category Group Button
    private func categoryGroupButton(categoryGroup: CategoryGroup, type: GroupType) -> some View {
        VStack(spacing: 4) {
            Image(categoryGroup.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(.primary)
                .padding(14)
                .background(
                    Circle()
                        .fill(Color.mainRowBackground)
                )
                .glassEffect(.regular)
            
            Text(categoryGroup.name)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(formatAmount(getTotalAmount(for: categoryGroup)))
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(type == .income ? .green : .red)
                .lineLimit(1)
        }
    }
    
    // MARK: - Helper Methods
    
    private func hasTransactions(for categoryGroup: CategoryGroup) -> Bool {
        let groupCategories = categories.filter { $0.categoryGroup.id == categoryGroup.id }
        let categoryIds = Set(groupCategories.map { $0.id })
        
        return filteredTransactions.contains { transaction in
            guard let categoryId = transaction.category?.id else { return false }
            return categoryIds.contains(categoryId)
        }
    }
    
    private func getTotalAmount(for categoryGroup: CategoryGroup) -> Decimal {
        let groupCategories = categories.filter { $0.categoryGroup.id == categoryGroup.id }
        let categoryIds = Set(groupCategories.map { $0.id })
        
        return filteredTransactions.filter { transaction in
            guard let categoryId = transaction.category?.id else { return false }
            return categoryIds.contains(categoryId)
        }.reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Enhanced Category Group Overview Detail View

struct CategoryGroupOverviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categories: [Category]
    
    let categoryGroup: CategoryGroup
    let filteredTransactions: [Transaction]
    
    private var groupCategories: [Category] {
        categories
            .filter { $0.categoryGroup.id == categoryGroup.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        List {
            if groupCategories.isEmpty {
                Section {
                    EmptyView(isGroups: false)
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(groupCategories) { category in
                        CategoryOverviewRow(
                            category: category,
                            transactionCount: getTransactionCount(for: category),
                            totalAmount: getTotalAmount(for: category)
                        )
                    }
                }
            }
        }
        .navigationTitle(categoryGroup.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Methods
    
    private func getTransactionCount(for category: Category) -> Int {
        filteredTransactions.filter { transaction in
            transaction.category?.id == category.id
        }.count
    }
    
    private func getTotalAmount(for category: Category) -> Decimal {
        filteredTransactions.filter { transaction in
            transaction.category?.id == category.id
        }.reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
}

// MARK: - Category Overview Row

struct CategoryOverviewRow: View {
    let category: Category
    let transactionCount: Int
    let totalAmount: Decimal
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(category.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.secondary)
            
            // Category info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("\(transactionCount) transactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(formatAmount(totalAmount))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(category.categoryGroup.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
