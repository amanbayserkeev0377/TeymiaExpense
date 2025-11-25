import SwiftUI
import SwiftData

struct OverviewCategoryButton: View {
    let category: Category
    let totalAmount: Decimal
    let transactionCount: Int
    let color: Color
    let currencies: [Currency]
    let userPreferences: UserPreferences
    
    var body: some View {
        VStack(spacing: 8) {
            // Circle with icon
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.07))
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.1), radius: 8)
                
                Image(category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
            }
            
            // Category info
            VStack(spacing: 4) {
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(userPreferences.formatAmountWithoutCurrency(totalAmount, currencies: currencies))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                    .lineLimit(1)
            }
        }
    }
}
