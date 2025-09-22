import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: GroupType = .expense
    @State private var selectedGroup: CategoryGroup?
    @State private var showingEditGroup = false
    @State private var showingEditCategory = false
    @State private var groupToEdit: CategoryGroup?
    @State private var categoryToEdit: Category?
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            List {
                // Groups Section
                Section("Groups") {
                    ForEach(filteredCategoryGroups, id: \.id) { group in
                        Button {
                            selectedGroup = group
                        } label: {
                            CategoryGroupRowView(
                                group: group,
                                isSelected: selectedGroup?.id == group.id
                            )
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button {
                                groupToEdit = group
                                showingEditGroup = true
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .tint(.blue)
                            
                            Button(role: .destructive) {
                                confirmDeleteGroup(group)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    .onMove(perform: moveGroups)
                }
                
                // Categories Section
                if let selectedGroup = selectedGroup {
                    Section("Categories in \(selectedGroup.name)") {
                        let groupCategories = categoriesForGroup(selectedGroup)
                        
                        if groupCategories.isEmpty {
                            Text("No categories yet")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(groupCategories, id: \.id) { category in
                                CategoryRowView(category: category)
                                    .swipeActions {
                                        Button {
                                            categoryToEdit = category
                                            showingEditCategory = true
                                        } label: {
                                            Image(systemName: "pencil")
                                        }
                                        .tint(.blue)
                                        
                                        Button(role: .destructive) {
                                            confirmDeleteCategory(category)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Picker("Type", selection: $selectedType) {
                        Text("Expense").tag(GroupType.expense)
                        Text("Income").tag(GroupType.income)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
        .onAppear {
            if selectedGroup == nil {
                selectedGroup = filteredCategoryGroups.first
            }
        }
        .onChange(of: selectedType) { _, _ in
            selectedGroup = filteredCategoryGroups.first
        }
        .sheet(isPresented: $showingEditGroup) {
            if let group = groupToEdit {
                CategoryGroupFormView(editingGroup: group)
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showingEditCategory) {
            if let category = categoryToEdit {
                CategoryFormView(
                    selectedCategoryGroup: category.categoryGroup,
                    editingCategory: category
                )
                .presentationDragIndicator(.visible)
            }
        }
        .alert("Are you sure you want to delete?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                pendingDeleteAction = nil
            }
            Button("Delete", role: .destructive) {
                pendingDeleteAction?()
                pendingDeleteAction = nil
            }
        } message: {
            Text(deleteAlertMessage)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredCategoryGroups: [CategoryGroup] {
        categoryGroups
            .filter { $0.type == selectedType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func categoriesForGroup(_ group: CategoryGroup) -> [Category] {
        categories
            .filter { $0.categoryGroup.id == group.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Helper Methods
    
    private func moveGroups(from source: IndexSet, to destination: Int) {
        // Create a copy of the array to avoid mutation during iteration
        let groups = filteredCategoryGroups
        var mutableGroups = groups
        mutableGroups.move(fromOffsets: source, toOffset: destination)
        
        // Update sort order
        for (index, group) in mutableGroups.enumerated() {
            group.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    private func confirmDeleteGroup(_ group: CategoryGroup) {
        let categoryCount = categoriesForGroup(group).count
        if categoryCount > 0 {
            deleteAlertMessage = "This will delete the group and its \(categoryCount) categories. All associated transactions will also be deleted."
        } else {
            deleteAlertMessage = "This will delete the group. All associated transactions will also be deleted."
        }
        
        pendingDeleteAction = { [weak modelContext] in
            withAnimation {
                modelContext?.delete(group)
                try? modelContext?.save()
            }
        }
        showingDeleteAlert = true
    }
    
    private func confirmDeleteCategory(_ category: Category) {
        deleteAlertMessage = "This will delete the category. All associated transactions will also be deleted."
        
        pendingDeleteAction = { [weak modelContext] in
            withAnimation {
                modelContext?.delete(category)
                try? modelContext?.save()
            }
        }
        showingDeleteAlert = true
    }
}

// MARK: - Supporting Views

struct CategoryGroupRowView: View {
    let group: CategoryGroup
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(group.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("\(group.categories.count) categories")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 2)
    }
}

struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(category.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundStyle(.secondary)
            
            Text(category.name)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.vertical, 1)
    }
}
