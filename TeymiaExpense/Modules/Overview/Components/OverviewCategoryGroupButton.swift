import SwiftUI
import SwiftData

struct OverviewCategoryGroupButton: View {
    let categoryGroup: CategoryGroup
    let totalAmount: Decimal
    let color: Color
    let currencies: [Currency]
    let userPreferences: UserPreferences
    let animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 8) {
            // Glass Circle
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(Color.mainRowBackground.opacity(0.7))
                    .overlay {
                        // Glass border
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1),
                                        .white.opacity(0.1),
                                        .white.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.15), radius: 10)
                
                // Icon
                Image(categoryGroup.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
            }

            // Text content
            VStack(spacing: 4) {
                Text(categoryGroup.name)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(userPreferences.formatAmountWithoutCurrency(totalAmount, currencies: currencies))
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minWidth: 140)
    }
}
