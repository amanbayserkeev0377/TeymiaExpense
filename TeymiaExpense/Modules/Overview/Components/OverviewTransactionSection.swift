import SwiftUI
import SwiftData

struct OverviewTransactionSection: View {
    let title: String
    let total: Decimal
    let color: Color
    let groups: [CategoryGroup]
    let filteredTransactions: [Transaction]
    let categories: [Category]
    let currencies: [Currency]
    let userPreferences: UserPreferences
    let onGroupSelected: (CategoryGroup) -> Void
    let animation: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(userPreferences.formatAmount(total, currencies: currencies))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 16
            ) {
                ForEach(groups) { categoryGroup in
                    Button {
                        onGroupSelected(categoryGroup)
                    } label: {
                        OverviewCategoryGroupButton(
                            categoryGroup: categoryGroup,
                            totalAmount: getTotalAmount(for: categoryGroup),
                            color: color,
                            currencies: currencies,
                            userPreferences: userPreferences
                        )
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: "categoryGroup-\(categoryGroup.id)", in: animation)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTotalAmount(for categoryGroup: CategoryGroup) -> Decimal {
        let groupCategories = categories.filter { $0.categoryGroup.id == categoryGroup.id }
        let categoryIds = Set(groupCategories.map { $0.id })
        
        return filteredTransactions.filter { transaction in
            guard let categoryId = transaction.category?.id else { return false }
            return categoryIds.contains(categoryId)
        }.reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
}
