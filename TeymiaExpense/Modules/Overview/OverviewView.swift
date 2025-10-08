import SwiftUI
import SwiftData

struct OverviewView: View {
    @Namespace private var animation
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    @Query private var allTransactions: [Transaction]
    @Query private var currencies: [Currency]
    
    @State private var selectedCategoryGroup: CategoryGroup?
    
    // Date filtering state
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return allTransactions.filter { transaction in
            !transaction.isHidden &&
            transaction.date >= startOfStartDate &&
            transaction.date < endOfEndDate &&
            transaction.type != .transfer
        }
    }
    
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
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    dateFilterHeader
                    expensesSection
                    incomeSection
                    emptyStateSection
                }
                .padding(.vertical, 20)
            }
            .background {
                AnimatedBlobBackground()
            }
        }
        .sheet(item: $selectedCategoryGroup) { categoryGroup in
            NavigationStack {
                CategoryGroupOverviewView(
                    categoryGroup: categoryGroup,
                    filteredTransactions: filteredTransactions,
                    startDate: startDate,
                    endDate: endDate
                )
            }
            .presentationDragIndicator(.visible)
            .navigationTransition(.zoom(sourceID: "categoryGroup-\(categoryGroup.id)", in: animation))
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var dateFilterHeader: some View {
        HStack {
            Text(dateRangeText)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
            
            Spacer()
            
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
    }
    
    @ViewBuilder
    private var expensesSection: some View {
        if !expenseGroupsWithTransactions.isEmpty {
            OverviewTransactionSection(
                title: "Expenses",
                total: totalExpenses,
                color: Color("ExpenseColor"),
                groups: expenseGroupsWithTransactions,
                filteredTransactions: filteredTransactions,
                categories: categories,
                currencies: currencies,
                userPreferences: userPreferences,
                onGroupSelected: { selectedCategoryGroup = $0 },
                animation: animation
            )
        }
    }
    
    @ViewBuilder
    private var incomeSection: some View {
        if !incomeGroupsWithTransactions.isEmpty {
            OverviewTransactionSection(
                title: "Income",
                total: totalIncome,
                color: Color("IncomeColor"),
                groups: incomeGroupsWithTransactions,
                filteredTransactions: filteredTransactions,
                categories: categories,
                currencies: currencies,
                userPreferences: userPreferences,
                onGroupSelected: { selectedCategoryGroup = $0 },
                animation: animation
            )
        }
    }
    
    @ViewBuilder
    private var emptyStateSection: some View {
        if expenseGroupsWithTransactions.isEmpty && incomeGroupsWithTransactions.isEmpty {
            TransactionEmptyStateView()
                .padding(.top, 60)
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
}
