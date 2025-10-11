import SwiftUI
import SwiftData

struct CategorySelectionRow: View {
    let selectedCategory: Category?
    
    var body: some View {
        HStack {
            Image(selectedCategory?.iconName ?? "other")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
            
            Text("category".localized)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let category = selectedCategory {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(category.categoryGroup?.name ?? "other".localized)
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
    
    let transactionType: GroupType
    let selectedCategory: Category?
    let onSelectionChanged: (Category?) -> Void
    
    @State private var localSelectedCategoryGroup: CategoryGroup?
    @State private var showingCategoryManagement = false
    
    private var filteredCategoryGroups: [CategoryGroup] {
        return categoryGroups
            .filter { $0.type == transactionType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var categoriesForSelectedGroup: [Category] {
        guard let selectedGroup = localSelectedCategoryGroup else { return [] }
        
        return categories
            .filter { $0.categoryGroup?.id == selectedGroup.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Groups Section
                ScrollView {
                    if filteredCategoryGroups.isEmpty {
                        CategoryEmptyStateView(isGroups: true)
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
                .background(Color.mainBackground)
                .frame(height: 300)
                
                Divider()
                
                // Categories Section
                List {
                    if categoriesForSelectedGroup.isEmpty && !filteredCategoryGroups.isEmpty {
                        Section {
                            CategoryEmptyStateView(isGroups: false)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        Section {
                            ForEach(categoriesForSelectedGroup) { category in
                                categoryRow(category: category)
                            }
                        }
                        .listRowBackground(Color.mainRowBackground)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(.mainBackground)
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCategoryManagement = true
                } label: {
                    Image(systemName: "pencil")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if localSelectedCategoryGroup == nil {
                if let category = selectedCategory {
                    localSelectedCategoryGroup = category.categoryGroup
                } else {
                    localSelectedCategoryGroup = filteredCategoryGroups.first
                }
            }
        }
        .sheet(isPresented: $showingCategoryManagement) {
            CategoryManagementView(initialType: transactionType)
                .presentationDragIndicator(.visible)
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
                                  ? .primary
                                  : Color.mainRowBackground)
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
                        .foregroundStyle(.appTint)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
