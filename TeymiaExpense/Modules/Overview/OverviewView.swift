import SwiftUI
import SwiftData

struct OverviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var categories: [Category]
    @Query private var allTransactions: [Transaction]
    
    @State private var selectedCategory: Category?
    
    @State private var startDate = Date.startOfCurrentMonth
    @State private var endDate = Date.endOfCurrentMonth
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
        
        return allTransactions.filter { transaction in
            transaction.date >= startOfStartDate &&
            transaction.date < endOfEndDate &&
            transaction.type != .transfer
        }
    }
    
    private var expenseCategoriesWithTransactions: [Category] {
        categories
            .filter { $0.type == .expense && hasTransactions(for: $0) }
            .sorted { getTotalAmount(for: $0) > getTotalAmount(for: $1) }
    }
    
    private var incomeCategoriesWithTransactions: [Category] {
        categories
            .filter { $0.type == .income && hasTransactions(for: $0) }
            .sorted { getTotalAmount(for: $0) > getTotalAmount(for: $1) }
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
                BackgroundView()
            }
        }
        .sheet(item: $selectedCategory) { category in
            NavigationStack {
                CategoryTransactionsView(
                    category: category,
                    startDate: startDate,
                    endDate: endDate
                )
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var dateFilterHeader: some View {
        HStack {
            Text(dateRangeText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            CustomMenuView() {
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
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var expensesSection: some View {
        if !expenseCategoriesWithTransactions.isEmpty {
            OverviewCategorySection(
                title: "expenses".localized,
                total: totalExpenses,
                color: Color("ExpenseColor"),
                categories: expenseCategoriesWithTransactions,
                filteredTransactions: filteredTransactions,
                userPreferences: userPreferences,
                onCategorySelected: { selectedCategory = $0 }
            )
        }
    }
    
    @ViewBuilder
    private var incomeSection: some View {
        if !incomeCategoriesWithTransactions.isEmpty {
            OverviewCategorySection(
                title: "income".localized,
                total: totalIncome,
                color: Color("IncomeColor"),
                categories: incomeCategoriesWithTransactions,
                filteredTransactions: filteredTransactions,
                userPreferences: userPreferences,
                onCategorySelected: { selectedCategory = $0 }
            )
        }
    }
    
    @ViewBuilder
    private var emptyStateSection: some View {
        if expenseCategoriesWithTransactions.isEmpty && incomeCategoriesWithTransactions.isEmpty {
            ContentUnavailableView(
                "no_transactions".localized,
                systemImage: "magnifyingglass"
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func hasTransactions(for category: Category) -> Bool {
        filteredTransactions.contains { transaction in
            // ИСПРАВЛЕНО: category больше не опциональна внутри SwiftData связи, если настроена правильно
            transaction.category?.id == category.id
        }
    }
    
    private func getTotalAmount(for category: Category) -> Decimal {
        filteredTransactions
            .filter { $0.category?.id == category.id }
            .reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
}
