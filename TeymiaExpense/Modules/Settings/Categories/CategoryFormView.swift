import SwiftUI
import SwiftData

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    private let editingCategory: Category?
    private let categoryType: CategoryType
    
    @State private var categoryName: String
    @State private var selectedIcon: String
    @State private var showingIconSelection = false
    
    // MARK: - Initializers
    
    /// Create form for adding new category
    init(categoryType: CategoryType) {
        self.editingCategory = nil
        self.categoryType = categoryType
        self._categoryName = State(initialValue: "")
        self._selectedIcon = State(initialValue: "general")
    }
    
    /// Create form for editing existing category
    init(editingCategory: Category) {
        self.editingCategory = editingCategory
        self.categoryType = editingCategory.type
        self._categoryName = State(initialValue: editingCategory.name)
        self._selectedIcon = State(initialValue: editingCategory.iconName)
    }
    
    private var isEditing: Bool {
        editingCategory != nil
    }
    
    private var navigationTitle: String {
        isEditing ? "Edit Category" : "New Category"
    }
    
    private var canSave: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Category Type (read-only)
                    HStack {
                        Text("Type")
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(categoryType == .expense ? "Expense" : "Income")
                            .foregroundStyle(.secondary)
                    }
                    
                    // Category Name
                    TextField("Category Name", text: $categoryName)
                        .autocorrectionDisabled()
                    
                    // Icon Selection
                    Button {
                        showingIconSelection = true
                    } label: {
                        HStack {
                            Image(selectedIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.primary)
                            
                            Text("Icon")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.mainRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .sheet(isPresented: $showingIconSelection) {
            CategoryIconSelectionView(selectedIcon: $selectedIcon)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Actions
    
    private func save() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingCategory = editingCategory {
            // Update existing category
            existingCategory.name = trimmedName
            existingCategory.iconName = selectedIcon
        } else {
            // Create new category
            let sortOrder = categories.filter { $0.type == categoryType }.count
            let newCategory = Category(
                name: trimmedName,
                iconName: selectedIcon,
                type: categoryType,
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
