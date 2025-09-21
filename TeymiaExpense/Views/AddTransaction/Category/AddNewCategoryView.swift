import SwiftUI
import SwiftData

struct AddNewCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    let selectedCategoryGroup: CategoryGroup
    
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "general"
    
    init(selectedCategoryGroup: CategoryGroup) {
        self.selectedCategoryGroup = selectedCategoryGroup
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
                }
            }
            .navigationTitle("New Category")
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
                        saveCategory()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Helper Methods
    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sortOrder = categories.filter { $0.categoryGroup.id == selectedCategoryGroup.id }.count
        
        let newCategory = Category(
            name: trimmedName,
            iconName: selectedIcon,
            categoryGroup: selectedCategoryGroup,
            sortOrder: sortOrder,
            isDefault: false
        )
        
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving category: \(error)")
        }
    }
}
