import SwiftUI
import SwiftData

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    let selectedCategoryGroup: CategoryGroup
    let editingCategory: Category? // nil = add new, value = edit existing
    
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "general"
    @State private var showingIconSelection = false
    
    init(selectedCategoryGroup: CategoryGroup, editingCategory: Category? = nil) {
        self.selectedCategoryGroup = selectedCategoryGroup
        self.editingCategory = editingCategory
    }
    
    private var isEditing: Bool {
        editingCategory != nil
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
            }
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            setupInitialValues()
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
    private func setupInitialValues() {
        if let category = editingCategory {
            // Edit mode - populate with existing values
            categoryName = category.name
            selectedIcon = category.iconName
        }
        // Add mode uses default values from @State initialization
    }
    
    private func save() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingCategory = editingCategory {
            // Update existing category
            existingCategory.name = trimmedName
            existingCategory.iconName = selectedIcon
        } else {
            // Create new category
            let sortOrder = categories.filter { $0.categoryGroup.id == selectedCategoryGroup.id }.count
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
