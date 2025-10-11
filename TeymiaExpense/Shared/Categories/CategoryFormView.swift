import SwiftUI
import SwiftData

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    let selectedCategoryGroup: CategoryGroup
    let editingCategory: Category? // nil = add new, value = edit existing
    
    @State private var categoryName: String
    @State private var selectedIcon: String
    @State private var showingIconSelection = false
    
    // MARK: - Proper initialization in init
    init(selectedCategoryGroup: CategoryGroup, editingCategory: Category? = nil) {
        self.selectedCategoryGroup = selectedCategoryGroup
        self.editingCategory = editingCategory
        
        // Initialize @State properties based on editingCategory
        if let category = editingCategory {
            // Edit mode - initialize with existing values
            self._categoryName = State(initialValue: category.name)
            self._selectedIcon = State(initialValue: category.iconName)
        } else {
            // Add mode - initialize with defaults
            self._categoryName = State(initialValue: "")
            self._selectedIcon = State(initialValue: "general")
        }
    }
    
    private var isEditing: Bool {
        editingCategory != nil
    }
    
    private var navigationTitle: String {
        isEditing ? "Edit Category" : "New Category"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Show selected group (read-only)
                    HStack {
                        Image(selectedCategoryGroup.iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Group")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(selectedCategoryGroup.name)
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                    }
                }
                .listRowBackground(Color.mainRowBackground)
                
                Section {
                    TextField("Category Name", text: $categoryName)
                        .autocorrectionDisabled()
                    
                    NavigationLink {
                        CategoryIconSelectionView(selectedIcon: $selectedIcon)
                    } label: {
                        HStack {
                            Image(selectedIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.primary)
                            
                            Text("icon".localized)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.mainRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .disabled(!canSave)
                }
            }
        }
        .sheet(isPresented: $showingIconSelection) {
            CategoryIconSelectionView(selectedIcon: $selectedIcon)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Helper Methods
    private func save() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingCategory = editingCategory {
            // Update existing category
            existingCategory.name = trimmedName
            existingCategory.iconName = selectedIcon
        } else {
            // Create new category
            let sortOrder = categories.filter { $0.categoryGroup?.id == selectedCategoryGroup.id }.count
            let newCategory = Category(
                name: trimmedName,
                iconName: selectedIcon,
                categoryGroup: selectedCategoryGroup,
                sortOrder: sortOrder,
                isDefault: false
            )
            modelContext.insert(newCategory)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving category: \(error)")
        }
    }
}
