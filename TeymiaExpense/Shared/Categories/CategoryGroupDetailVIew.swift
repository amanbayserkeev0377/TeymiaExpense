import SwiftUI
import SwiftData

struct CategoryGroupDetailView: View {
    let categoryGroup: CategoryGroup
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditMode = false
    
    // MARK: - Simplified sheet state
    @State private var editingCategory: Category?
    @State private var showingAddCategory = false
    
    // Delete confirmation
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    
    // Computed property for sheet binding
    private var showingEditCategory: Binding<Bool> {
        Binding(
            get: { editingCategory != nil },
            set: { if !$0 { editingCategory = nil } }
        )
    }
    
    private var groupCategories: [Category] {
        categories
            .filter { $0.categoryGroup?.id == categoryGroup.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        List {
            if groupCategories.isEmpty {
                Section {
                    CategoryEmptyStateView(isGroups: false)
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(groupCategories, id: \.id) { category in
                        CategoryActionRow(
                            category: category,
                            onEdit: { editingCategory = category },
                            onDelete: { confirmDeleteCategory(category) }
                        )
                    }
                    .onMove(perform: isEditMode ? moveCategories : nil)
                } footer: {
                    Text("Tap to edit or swipe left for more options.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .scrollContentBackground(.hidden)
        .background(.mainBackground)
        .navigationTitle(categoryGroup.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(selectedCategoryGroup: categoryGroup)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: showingEditCategory) {
            if let category = editingCategory {
                CategoryFormView(selectedCategoryGroup: categoryGroup, editingCategory: category)
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
    
    // MARK: - View Components
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditMode.toggle()
                }
            } label: {
                Image(systemName: isEditMode ? "checkmark" : "pencil")
                    .fontWeight(.semibold)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingAddCategory = true
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
            }
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
