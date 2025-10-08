import SwiftUI
import SwiftData

struct OverviewCategoryGroupButton: View {
    let categoryGroup: CategoryGroup
    let totalAmount: Decimal
    let color: Color
    let currencies: [Currency]
    let userPreferences: UserPreferences
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glass effect background
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 10, opaque: true)
                    .background(Color.white.opacity(0.05))
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
                    .frame(width: 52, height: 52)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Icon on top
                Image(categoryGroup.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
            }
            
            // Текстовое содержимое
            VStack(spacing: 4) {
                Text(categoryGroup.name)
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(userPreferences.formatAmount(totalAmount, currencies: currencies))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}
