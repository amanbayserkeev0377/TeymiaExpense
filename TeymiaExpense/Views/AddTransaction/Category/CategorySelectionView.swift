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
    
    @State private var searchText = ""
    @State private var localSelectedCategoryGroup: CategoryGroup?
    
    private var filteredCategoryGroups: [CategoryGroup] {
        let groupType: GroupType = transactionType == .income ? .income : .expense
        return categoryGroups
            .filter { $0.type == groupType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var categoriesForSelectedGroup: [Category] {
        guard let selectedGroup = localSelectedCategoryGroup else { return [] }
        
        let filtered = categories.filter { $0.categoryGroup.id == selectedGroup.id }
        
        if searchText.isEmpty {
            return filtered.sorted { $0.sortOrder < $1.sortOrder }
        }
        
        return filtered
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Section {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                                spacing: 16
                            ) {
                                ForEach(filteredCategoryGroups) { categoryGroup in
                                    categoryGroupButton(categoryGroup: categoryGroup)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .frame(height: 300)
                
                Divider()
                
                List {
                    Section("Categories") {
                        if categoriesForSelectedGroup.isEmpty && searchText.isEmpty {
                            // Show "Add first category" button when no categories in group
                            NavigationLink {
                                if let selectedGroup = localSelectedCategoryGroup {
                                    AddNewCategoryView(selectedCategoryGroup: selectedGroup)
                                }
                            } label: {
                                Label("Add first category", systemImage: "plus")
                                    .foregroundStyle(.app)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else if categoriesForSelectedGroup.isEmpty && !searchText.isEmpty {
                            // Show search empty state
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                
                                Text("No categories found")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text("Try a different search term")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 140)
                            .listRowBackground(Color.clear)
                        } else {
                            // Show categories + "Add category" button at the end
                            ForEach(categoriesForSelectedGroup) { category in
                                categoryRow(category: category)
                            }
                            
                            // Add category button at the end of list
                            NavigationLink {
                                if let selectedGroup = localSelectedCategoryGroup {
                                    AddNewCategoryView(selectedCategoryGroup: selectedGroup)
                                }
                            } label: {
                                Label("Add new category", systemImage: "plus")
                                    .foregroundStyle(.app)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.05))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    CategoryManagementView()
                } label: {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddNewCategoryGroupView()
                    } label: {
                        Image(systemName: "plus")
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
                                  ? Color.primary.opacity(0.9)
                                  : Color.secondary.opacity(0.1))
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
