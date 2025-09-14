import SwiftUI
import SwiftData

struct CategorySelectionRow: View {
    let selectedCategory: Category?
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                if let category = selectedCategory {
                    Image(category.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.primary)
                    
                    Text("category".localized)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(category.name)
                        .foregroundColor(.secondary)
                    
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categories: [Category]
    
    let transactionType: AddTransactionView.TransactionType
    let selectedCategory: Category?
    let onCategorySelected: (Category) -> Void
    
    private var filteredCategories: [Category] {
        let categoryType: CategoryType = transactionType == .income ? .income : .expense
        return categories.filter { $0.type == categoryType }
    }
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 20) {
                        ForEach(filteredCategories) { category in
                            categoryButton(category: category)
                        }
                    }
                    .padding(20)
                    .padding(.top, 20)
                }
            }
        }
    
    private func categoryButton(category: Category) -> some View {
        Button {
            onCategorySelected(category)
            dismiss()
        } label: {
            VStack(spacing: 8) {
                Image(category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(
                        selectedCategory?.id == category.id
                        ? (colorScheme == .light ? Color.white : Color.black)
                        : Color.primary
                    )
                    .padding(14)
                    .background(
                        Circle()
                            .fill(selectedCategory?.id == category.id
                                  ? Color.primary.opacity(0.9)
                                  : Color.secondary.opacity(0.1))
                    )
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(.plain)
    }
}
