import SwiftUI
import SwiftData

struct OverviewCategoryGroupButton: View {
    let categoryGroup: CategoryGroup
    let totalAmount: Decimal
    let color: Color
    let currencies: [Currency]
    let userPreferences: UserPreferences
    
    var body: some View {
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
            
            Text(userPreferences.formatAmount(totalAmount, currencies: currencies))
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .lineLimit(1)
        }
    }
}
