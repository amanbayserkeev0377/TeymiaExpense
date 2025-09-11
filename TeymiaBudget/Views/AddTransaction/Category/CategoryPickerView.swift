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
            VStack(spacing: 20) {
                
                // Categories Grid
                categoriesGridSection
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Categories Grid Section
    private var categoriesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(transactionType.rawValue) Categories")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            ScrollView {
                if filteredCategories.isEmpty {
                    emptyStateView
                } else {
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No \(transactionType.rawValue.lowercased()) categories")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Add some categories to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
