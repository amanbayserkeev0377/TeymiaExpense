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
    
    // Sheet states
    @State private var showingCategoryManagement = false
    @State private var showingAddCategoryGroup = false
    @State private var showingAddCategory = false
    
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
                .background(Color(.systemGroupedBackground))
                .frame(height: 300)
                
                Divider()
                
                List {
                    Section("Categories") {
                        // Show categories
                        ForEach(categoriesForSelectedGroup) { category in
                            categoryRow(category: category)
                        }
                        
                        // Always show "Add new category" button
                        Button {
                            showingAddCategory = true
                        } label: {
                            Label("Add new category", systemImage: "plus")
                                .foregroundStyle(.app)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(.plain)
                    }
                }
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
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddCategoryGroup = true
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
        // Sheet presentations
        .sheet(isPresented: $showingCategoryManagement) {
            CategoryManagementView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddCategoryGroup) {
            AddNewCategoryGroupView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddCategory) {
            if let selectedGroup = localSelectedCategoryGroup ?? filteredCategoryGroups.first {
                AddNewCategoryView(selectedCategoryGroup: selectedGroup)
                    .presentationDragIndicator(.visible)
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
