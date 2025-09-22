import SwiftUI
import SwiftData

struct CategorySelectionRow: View {
    let selectedCategory: Category?
    
    var body: some View {
        HStack {
            Image(selectedCategory?.iconName ?? "circle.dashed")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
            
            Text("category".localized)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let category = selectedCategory {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(category.categoryGroup.name)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(category.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    
    let transactionType: AddTransactionView.TransactionType
    let selectedCategory: Category?
    let onSelectionChanged: (Category?) -> Void
    
    @State private var localSelectedCategoryGroup: CategoryGroup?
    
    private var filteredCategoryGroups: [CategoryGroup] {
        let groupType: GroupType = transactionType == .income ? .income : .expense
        return categoryGroups
            .filter { $0.type == groupType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var categoriesForSelectedGroup: [Category] {
        guard let selectedGroup = localSelectedCategoryGroup else { return [] }
        
        return categories
            .filter { $0.categoryGroup.id == selectedGroup.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Groups Section
                ScrollView {
                    if filteredCategoryGroups.isEmpty {
                        EmptyView(isGroups: true)
                    } else {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                            spacing: 16
                        ) {
                            ForEach(filteredCategoryGroups) { categoryGroup in
                                categoryGroupButton(categoryGroup: categoryGroup)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .frame(height: 300)
                
                Divider()
                
                // Categories Section
                List {
                    if categoriesForSelectedGroup.isEmpty {
                        Section {
                            EmptyView(isGroups: false)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ForEach(categoriesForSelectedGroup) { category in
                                categoryRow(category: category)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if localSelectedCategoryGroup == nil {
                if let category = selectedCategory {
                    localSelectedCategoryGroup = category.categoryGroup
                } else {
                    localSelectedCategoryGroup = filteredCategoryGroups.first
                }
            }
        }
    }
    
    // MARK: - CategoryGroup Button
    private func categoryGroupButton(categoryGroup: CategoryGroup) -> some View {
        Button {
            localSelectedCategoryGroup = categoryGroup
        } label: {
            VStack(spacing: 8) {
                Image(categoryGroup.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(
                        localSelectedCategoryGroup?.id == categoryGroup.id
                        ? (colorScheme == .light ? Color.white : Color.black)
                        : Color.primary
                    )
                    .padding(14)
                    .background(
                        Circle()
                            .fill(localSelectedCategoryGroup?.id == categoryGroup.id
                                  ? Color.primary
                                  : Color(.secondarySystemGroupedBackground))
                    )
                
                Text(categoryGroup.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Category Row
    private func categoryRow(category: Category) -> some View {
        Button {
            onSelectionChanged(category)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Image(category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
                
                Text(category.name)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if selectedCategory?.id == category.id {
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
