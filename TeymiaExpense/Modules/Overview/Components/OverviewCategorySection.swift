import SwiftUI
import SwiftData

struct OverviewCategorySection: View {
    let title: String
    let total: Decimal
    let color: Color
    let categories: [Category]
    let filteredTransactions: [Transaction]
    let userPreferences: UserPreferences
    let onCategorySelected: (Category) -> Void
    let zoomNamespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(userPreferences.formatAmount(total))
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color.gradient)
            }
            .padding(.horizontal, 16)
            
            Divider().opacity(0.3)
            
            // Categories Grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 16
            ) {
                ForEach(categories) { category in
                    Button {
                        onCategorySelected(category)
                    } label: {
                        OverviewCategoryButton(
                            category: category,
                            totalAmount: getTotalAmount(for: category),
                            transactionCount: getTransactionCount(for: category),
                            color: color,
                            userPreferences: userPreferences,
                            zoomNamespace: zoomNamespace
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTotalAmount(for category: Category) -> Decimal {
        filteredTransactions
            .filter { $0.category?.id == category.id }
            .reduce(Decimal.zero) { $0 + abs($1.amount) }
    }
    
    private func getTransactionCount(for category: Category) -> Int {
        filteredTransactions
            .filter { $0.category?.id == category.id }
            .count
    }
}
