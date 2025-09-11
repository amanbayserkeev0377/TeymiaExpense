import SwiftUI
import SwiftData

// MARK: - Category Grid View (4 columns, reusable)
struct CategoryGridView: View {
    let categories: [Category]
    let selectedCategory: Category?
    let transactionType: TransactionType
    let onCategorySelected: (Category) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(categories) { category in
                CategoryItemView(
                    category: category,
                    isSelected: selectedCategory?.id == category.id,
                    transactionType: transactionType,
                    onTap: {
                        onCategorySelected(category)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Category Item View (Circle + Label)
struct CategoryItemView: View {
    let category: Category
    let isSelected: Bool
    let transactionType: TransactionType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Circle with icon
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
            return .gray.opacity(0.15)
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
