import SwiftUI
import SwiftData

struct CategorySelectionRow: View {
    let selectedCategory: Category?
    let selectedSubcategory: Subcategory?
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(selectedSubcategory?.iconName ?? selectedCategory?.iconName ?? "")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
                
                Text("category".localized)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if let subcategory = selectedSubcategory {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(subcategory.category.name)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text(subcategory.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else if let category = selectedCategory {
                    Text(category.name)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var displayIcon: String {
        selectedSubcategory?.iconName ?? selectedCategory!.iconName
    }
    
}

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categories: [Category]
    @Query private var subcategories: [Subcategory]
    
    let transactionType: AddTransactionView.TransactionType
    let selectedCategory: Category?
    let selectedSubcategory: Subcategory?
    let onSelectionChanged: (Category?, Subcategory?) -> Void
    
    @State private var searchText = ""
    @State private var localSelectedCategory: Category?
    
    private var filteredCategories: [Category] {
        let categoryType: CategoryType = transactionType == .income ? .income : .expense
        return categories.filter { $0.type == categoryType }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var subcategoriesForSelectedCategory: [Subcategory] {
        guard let selectedCategory = localSelectedCategory else { return [] }
        
        let filtered = subcategories.filter { $0.category.id == selectedCategory.id }
        
        if searchText.isEmpty {
            return filtered.sorted { $0.sortOrder < $1.sortOrder }
        }
        
        return filtered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Half - Categories
                categoriesSection
                
                // Divider
                Divider()
                    .background(Color.secondary.opacity(0.3))
                
                // Bottom Half - Subcategories
                subcategoriesSection
            }
        }
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    // Если выбрана подкатегория - сохраняем её
                    if let subcategory = selectedSubcategory {
                        onSelectionChanged(subcategory.category, subcategory)
                    }
                    // Если выбрана только категория - сохраняем категорию
                    else if let category = localSelectedCategory {
                        onSelectionChanged(category, nil)
                    }
                    dismiss()
                }
                .disabled(localSelectedCategory == nil)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: Open Category Management View
                } label: {
                    Image(systemName: "pencil")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: Open Add Category View
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if localSelectedCategory == nil {
                if let subcategory = selectedSubcategory {
                    localSelectedCategory = subcategory.category
                } else {
                    localSelectedCategory = filteredCategories.first
                }
            }
        }
    }
    
    // MARK: - Categories Section (Top Half)
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Categories")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                Spacer()
            }
            
            // Categories Grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                    ForEach(filteredCategories) { category in
                        categoryButton(category: category)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 300) // Fixed height for top half
        }
    }
    
    // MARK: - Subcategories Section (Bottom Half)
    private var subcategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Subcategories")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                Spacer()
                
                if let selectedCategory = localSelectedCategory {
                    Text(selectedCategory.name)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }
            }
            
            // Subcategories List
            if subcategoriesForSelectedCategory.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No subcategories found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !searchText.isEmpty {
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(subcategoriesForSelectedCategory) { subcategory in
                    subcategoryRow(subcategory: subcategory)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    // MARK: - Category Button
    private func categoryButton(category: Category) -> some View {
        Button {
            localSelectedCategory = category
        } label: {
            VStack(spacing: 8) {
                Image(category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(
                        localSelectedCategory?.id == category.id
                        ? (colorScheme == .light ? Color.white : Color.black)
                        : Color.primary
                    )
                    .padding(14)
                    .background(
                        Circle()
                            .fill(localSelectedCategory?.id == category.id
                                  ? Color.primary.opacity(0.9)
                                  : Color(.secondarySystemGroupedBackground))
                    )
                
                Text(category.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Subcategory Row
    private func subcategoryRow(subcategory: Subcategory) -> some View {
        Button {
            onSelectionChanged(subcategory.category, subcategory)
        } label: {
            HStack(spacing: 12) {
                Image(subcategory.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
                
                Text(subcategory.name)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if selectedSubcategory?.id == subcategory.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.app)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
