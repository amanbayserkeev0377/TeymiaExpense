import SwiftUI
import SwiftData

// MARK: - Category Item View (Circle + Label)
struct CategoryItemView: View {
    let category: Category
    let isSelected: Bool
    let transactionType: TransactionType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(circleBackgroundColor)
                        .frame(width: 64, height: 64)
                    
                    Image(category.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(iconColor)
                }
                
                // Category name
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Colors based on selection and type
    private var circleBackgroundColor: Color {
        if isSelected {
            return colorForTransactionType(transactionType)
        } else {
            return .secondary.opacity(0.1)
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return .white
        } else {
            return colorForTransactionType(transactionType)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return colorForTransactionType(transactionType)
        } else {
            return .primary
        }
    }
    
    // MARK: - Helper Methods
    private func colorForTransactionType(_ type: TransactionType) -> Color {
        switch type {
        case .expense: return .red
        case .income: return .green
        }
    }
}
