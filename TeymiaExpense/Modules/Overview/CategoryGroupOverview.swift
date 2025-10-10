import SwiftUI
import SwiftData

// MARK: - Category Group Overview Detail View
struct CategoryGroupOverviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var categories: [Category]
    @Query private var currencies: [Currency]
    
    let categoryGroup: CategoryGroup
    let filteredTransactions: [Transaction]
    let startDate: Date
    let endDate: Date
    
    private var groupCategories: [Category] {
        categories
            .filter { $0.categoryGroup?.id == categoryGroup.id }
            .filter { getTransactionCount(for: $0) > 0 } // Show only categories with transactions
            .sorted { getTotalAmount(for: $0) > getTotalAmount(for: $1) } // Sort by amount descending
    }
    
    var body: some View {
        List {
            if groupCategories.isEmpty {
                Section {
                    CategoryEmptyStateView(isGroups: false)
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(groupCategories) { category in
                        NavigationLink {
                            CategoryTransactionsView(
                                category: category,
                                startDate: startDate,
                                endDate: endDate
                            )
                        } label: {
                            CategoryOverviewRow(
                                category: category,
                                transactionCount: getTransactionCount(for: category),
                                totalAmount: getTotalAmount(for: category),
                                currencies: currencies,
                                userPreferences: userPreferences
                            )
                        }
                    }
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .scrollContentBackground(.hidden)
        .background(.mainBackground)
        .navigationTitle(categoryGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
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
    let currencies: [Currency]
    let userPreferences: UserPreferences
    
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
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Text("\(transactionCount) transactions")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(userPreferences.formatAmount(totalAmount, currencies: currencies))
                .font(.body)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(category.categoryGroup?.type == .income ? Color("IncomeColor") : Color("ExpenseColor"))
        }
        .padding(.vertical, 4)
    }
}
