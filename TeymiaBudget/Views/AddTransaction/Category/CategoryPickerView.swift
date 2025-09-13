import SwiftUI
import SwiftData

// MARK: - Category Picker View (Sheet)
struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
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
                        CategoryItemView(
                            category: category,
                            isSelected: selectedCategory?.id == category.id,
                            transactionType: transactionType == .income ? .income : .expense,
                            onTap: {
                                onCategorySelected(category)
                                dismiss()
                            }
                        )
                    }
                }
                .padding(20)
                .padding(.top, 20)
            }
        }
    }
}
