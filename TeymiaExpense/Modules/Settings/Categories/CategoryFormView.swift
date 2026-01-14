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
    @State private var selectedColor: IconColor
    @State private var selectedHexColor: String?
    
    @FocusState private var isCategoryNameFocused: Bool
    
    // MARK: - Initializers
    
    init(categoryType: CategoryType) {
        self.editingCategory = nil
        self.categoryType = categoryType
        self._categoryName = State(initialValue: "")
        self._selectedIcon = State(initialValue: "general")
        self._selectedColor = State(initialValue: .color1)
        self._selectedHexColor = State(initialValue: nil)
    }
    
    init(editingCategory: Category) {
        self.editingCategory = editingCategory
        self.categoryType = editingCategory.type
        self._categoryName = State(initialValue: editingCategory.name)
        self._selectedIcon = State(initialValue: editingCategory.iconName)
        self._selectedColor = State(initialValue: editingCategory.iconColor)
        self._selectedHexColor = State(initialValue: editingCategory.hexColor)
    }
    
    private var previewColor: Color {
        if let hex = selectedHexColor {
            return Color(hex: hex)
        }
        return selectedColor.color
    }
    
    private var isEditing: Bool { editingCategory != nil }
    
    private var canSave: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CategoryIconPreviewView(iconName: selectedIcon, color: previewColor)
                }
                .listRowBackground(Color.clear)
                
                Section {
                    HStack {
                        TextField("category_name".localized, text: $categoryName)
                            .autocorrectionDisabled()
                            .focused($isCategoryNameFocused)
                            .fontDesign(.rounded)
                        
                        if !categoryName.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                    categoryName = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.secondary.opacity(0.5))
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    NavigationLink {
                        CategoryIconSelectionView(selectedIcon: $selectedIcon)
                    } label: {
                        Label {
                            Text("icon".localized)
                                .foregroundColor(.primary)
                        } icon: {
                            Image(selectedIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.primary)
                        }
                    }
                } header: {
                    Text(categoryType == .expense ? "expense".localized : "income".localized)
                }
                
                Section {
                    ColorSelectionView(selectedColor: $selectedColor, hexColor: $selectedHexColor)
                }
            }
            .navigationTitle(isEditing ? "edit_category".localized : "new_category".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()
                
                ConfirmationToolbarButton(
                    action: save,
                    isDisabled: !canSave
                )
            }
            .onAppear {
                if !isEditing {
                    DispatchQueue.main.async {
                        isCategoryNameFocused = true
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func save() {
        isCategoryNameFocused = false
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        withAnimation(.spring()) {
            if let existingCategory = editingCategory {
                existingCategory.name = trimmedName
                existingCategory.iconName = selectedIcon
                existingCategory.iconColor = selectedColor
                existingCategory.hexColor = selectedHexColor
            } else {
                let sortOrder = categories.filter { $0.type == categoryType }.count
                let newCategory = Category(
                    name: trimmedName,
                    iconName: selectedIcon,
                    type: categoryType,
                    iconColor: selectedColor,
                    hexColor: selectedHexColor,
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
                isCategoryNameFocused = true
            }
        }
    }
}
