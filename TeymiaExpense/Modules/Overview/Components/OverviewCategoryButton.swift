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
        VStack(spacing: 4) {
            // Circle with icon
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(category.iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
            }
            
            // Category info
            VStack(spacing: 4) {
                Text(category.name)
                    .font(.callout)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                Text(userPreferences.formatAmountWithoutCurrency(totalAmount, currencies: currencies))
                    .font(.callout)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
