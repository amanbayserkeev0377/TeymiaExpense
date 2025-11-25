import SwiftUI
import SwiftData

struct OverviewCategorySection: View {
    let title: String
    let total: Decimal
    let color: Color
    let categories: [Category]
    let filteredTransactions: [Transaction]
    let currencies: [Currency]
    let userPreferences: UserPreferences
    let onCategorySelected: (Category) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(userPreferences.formatAmount(total, currencies: currencies))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 20)
            
            Divider()
            
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
                            currencies: currencies,
                            userPreferences: userPreferences
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
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
