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
    @FocusState private var isCategoryNameFocused: Bool
    
    // MARK: - Initializers
    
    init(categoryType: CategoryType) {
        self.editingCategory = nil
        self.categoryType = categoryType
        self._categoryName = State(initialValue: "")
        self._selectedIcon = State(initialValue: "general")
    }
    
    init(editingCategory: Category) {
        self.editingCategory = editingCategory
        self.categoryType = editingCategory.type
        self._categoryName = State(initialValue: editingCategory.name)
        self._selectedIcon = State(initialValue: editingCategory.iconName)
    }
    
    private var isEditing: Bool { editingCategory != nil }
    
    private var canSave: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
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
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.primary)
                        }
                    }
                } header: {
                    Text(categoryType == .expense ? "expense".localized : "income".localized)
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.secondary.opacity(0.07))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(BackgroundView())
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
            } else {
                let sortOrder = categories.filter { $0.type == categoryType }.count
                let newCategory = Category(
                    name: trimmedName,
                    iconName: selectedIcon,
                    type: categoryType,
                    sortOrder: sortOrder
                )
                modelContext.insert(newCategory)
            }
            
            try? modelContext.save()
            dismiss()
        }
    }
}
