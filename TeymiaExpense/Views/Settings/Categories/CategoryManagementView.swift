import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categoryGroups: [CategoryGroup]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: GroupType = .expense
    @State private var showingAddGroup = false
    @State private var showingEditGroup = false
    @State private var editingGroup: CategoryGroup?
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    @State private var isEditMode = false
    
    private var filteredCategoryGroups: [CategoryGroup] {
        categoryGroups
            .filter { $0.type == selectedType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Type", selection: $selectedType) {
                        Text("expense".localized).tag(GroupType.expense)
                        Text("income".localized).tag(GroupType.income)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                
                if filteredCategoryGroups.isEmpty {
                    Section {
                        EmptyCategoryGroupsView(type: selectedType) {
                            showingAddGroup = true
                        }
                    }
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(filteredCategoryGroups, id: \.id) { group in
                            NavigationLink {
                                CategoryGroupDetailView(categoryGroup: group)
                            } label: {
                                CategoryGroupRowView(group: group)
                            }
                            .disabled(isEditMode) // Disable navigation when in edit mode
                            .swipeActions {
                                Button {
                                    editingGroup = group
                                    showingEditGroup = true
                                } label: {
                                    Image("edit")
                                }
                                .tint(.gray)
                                
                                Button(role: .destructive) {
                                    confirmDeleteGroup(group)
                                } label: {
                                    Image("trash.swipe")
                                }
                                .tint(.red)
                            }
                        }
                        .onMove(perform: isEditMode ? moveGroups : nil)
                    } footer: {
                        Text("Swipe left to edit or delete it.")
                    }
                }
            }
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                        }
                    } label: {
                        if isEditMode {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                        } else {
                            Image("edit")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            CategoryGroupFormView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingEditGroup) {
            CategoryGroupFormView(editingGroup: editingGroup)
                .presentationDragIndicator(.visible)
                .onDisappear {
                    editingGroup = nil
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
    
    // MARK: - Helper Methods
    
    private func moveGroups(from source: IndexSet, to destination: Int) {
        var groups = filteredCategoryGroups
        groups.move(fromOffsets: source, toOffset: destination)
        
        for (index, group) in groups.enumerated() {
            group.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    private func confirmDeleteGroup(_ group: CategoryGroup) {
        let categoryCount = group.categories.count
        if categoryCount > 0 {
            deleteAlertMessage = "This will delete the group and its \(categoryCount) categories. All associated transactions will also be deleted."
        } else {
            deleteAlertMessage = "This will delete the group. All associated transactions will also be deleted."
        }
        
        pendingDeleteAction = {
            withAnimation {
                modelContext.delete(group)
                try? modelContext.save()
            }
        }
        showingDeleteAlert = true
    }
}

// MARK: - Category Group Detail View

struct CategoryGroupDetailView: View {
    let categoryGroup: CategoryGroup
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddCategory = false
    @State private var showingEditGroup = false
    @State private var showingEditCategory = false
    @State private var editingCategory: Category?
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    @State private var isEditMode = false
    
    private var groupCategories: [Category] {
        categories
            .filter { $0.categoryGroup.id == categoryGroup.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        List {
            if groupCategories.isEmpty {
                Section {
                    EmptyCategoriesView(groupName: categoryGroup.name) {
                        showingAddCategory = true
                    }
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(groupCategories, id: \.id) { category in
                        CategoryRowView(category: category)
                            .swipeActions {
                                Button {
                                    editingCategory = category
                                    showingEditCategory = true
                                } label: {
                                    Image("edit")
                                }
                                .tint(.gray)
                                
                                Button(role: .destructive) {
                                    confirmDeleteCategory(category)
                                } label: {
                                    Image("trash.swipe")
                                }
                                .tint(.red)
                            }
                    }
                    .onMove(perform: isEditMode ? moveCategories : nil)
                } footer: {
                    Text("Swipe left to edit or delete it.")
                }
            }
        }
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .navigationTitle(categoryGroup.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Label("Add Category", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                    }
                } label: {
                    Image(systemName: isEditMode ? "checkmark" : "edit")
                        .fontWeight(.medium)
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(selectedCategoryGroup: categoryGroup)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingEditGroup) {
            CategoryGroupFormView(editingGroup: categoryGroup)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingEditCategory) {
            CategoryFormView(selectedCategoryGroup: categoryGroup, editingCategory: editingCategory)
                .presentationDragIndicator(.visible)
                .onDisappear {
                    editingCategory = nil
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
    
    // MARK: - Helper Methods
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var categories = groupCategories
        categories.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in categories.enumerated() {
            category.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    private func confirmDeleteCategory(_ category: Category) {
        deleteAlertMessage = "This will delete the category. All associated transactions will also be deleted."
        
        pendingDeleteAction = {
            withAnimation {
                modelContext.delete(category)
                try? modelContext.save()
            }
        }
        showingDeleteAlert = true
    }
}

// MARK: - Empty State Views

struct EmptyCategoryGroupsView: View {
    let type: GroupType
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image("drawer.empty")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.secondary)
            
            Text("No \(type.rawValue.capitalized) Groups")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct EmptyCategoriesView: View {
    let groupName: String
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image("drawer.empty")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.secondary)
            
            Text("No Categories")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Supporting Views

struct CategoryGroupRowView: View {
    let group: CategoryGroup
    
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
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(category.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.secondary)
            
            Text(category.name)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}
