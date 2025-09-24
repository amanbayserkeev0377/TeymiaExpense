import SwiftUI
import SwiftData

struct OverviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    @Query private var transactions: [Transaction]
    
    // Filter groups that have transactions
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Expenses Section
                    if !expenseGroupsWithTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Expenses")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                                spacing: 16
                            ) {
                                ForEach(expenseGroupsWithTransactions) { categoryGroup in
                                    NavigationLink {
                                        CategoryGroupOverviewView(categoryGroup: categoryGroup)
                                    } label: {
                                        categoryGroupButton(categoryGroup: categoryGroup, type: .expense)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Income Section
                    if !incomeGroupsWithTransactions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Income")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                                spacing: 16
                            ) {
                                ForEach(incomeGroupsWithTransactions) { categoryGroup in
                                    NavigationLink {
                                        CategoryGroupOverviewView(categoryGroup: categoryGroup)
                                    } label: {
                                        categoryGroupButton(categoryGroup: categoryGroup, type: .income)
                                    }
                                    .buttonStyle(.plain)
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
            .background {
                Color.mainBackground
            }
            .ignoresSafeArea(.all)
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
                        .fill(Color(.secondarySystemGroupedBackground))
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
        
        return transactions.contains { transaction in
            guard let categoryId = transaction.category?.id else { return false }
            return categoryIds.contains(categoryId) && !transaction.isHidden
        }
    }
    
    private func getTotalAmount(for categoryGroup: CategoryGroup) -> Decimal {
        let groupCategories = categories.filter { $0.categoryGroup.id == categoryGroup.id }
        let categoryIds = Set(groupCategories.map { $0.id })
        
        return transactions.filter { transaction in
            guard let categoryId = transaction.category?.id else { return false }
            return categoryIds.contains(categoryId) && !transaction.isHidden
        }.reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // You can make this dynamic
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Category Group Overview Detail View

struct CategoryGroupOverviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categories: [Category]
    @Query private var transactions: [Transaction]
    
    let categoryGroup: CategoryGroup
    
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
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Helper Methods
    
    private func getTransactionCount(for category: Category) -> Int {
        transactions.filter { transaction in
            transaction.category?.id == category.id && !transaction.isHidden
        }.count
    }
    
    private func getTotalAmount(for category: Category) -> Decimal {
        transactions.filter { transaction in
            transaction.category?.id == category.id && !transaction.isHidden
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
        formatter.currencyCode = "USD" // You can make this dynamic
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
