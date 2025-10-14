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
                    .blur(radius: 3, opaque: true)
                    .background(Color.mainRowBackground.opacity(0.5))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
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
                                lineWidth: 0.8
                            )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.08), radius: 6)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                // Icon on top
                Image(categoryGroup.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
            }
            .padding(10)
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
