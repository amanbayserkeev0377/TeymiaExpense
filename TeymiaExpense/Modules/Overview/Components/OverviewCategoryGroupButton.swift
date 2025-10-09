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
            ZStack {
                // Glass effect background
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 10, opaque: true)
                    .background(Color.mainRowBackground.opacity(0.8))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .clear,
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.07), radius: 6)
                
                // Icon on top
                Image(categoryGroup.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
            }
            .padding(2)
            .clipShape(Circle())
            .contentShape(Circle())
            .matchedTransitionSource(id: "categoryGroup-\(categoryGroup.id)", in: animation)

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
