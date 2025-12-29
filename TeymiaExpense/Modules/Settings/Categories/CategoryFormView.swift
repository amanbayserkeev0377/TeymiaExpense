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
    
    @FocusState private var isCategoryNameFocused: Bool

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
        isEditing ? "edit_category".localized : "new_category".localized
    }
    
    private var canSave: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(categoryType == .expense ? "expense".localized : "income".localized) {
                    HStack {
                        TextField("category_name".localized, text: $categoryName)
                            .autocorrectionDisabled()
                            .focused($isCategoryNameFocused)
                            .fontDesign(.rounded)
                            
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                categoryName = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.secondary.opacity(0.5))
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.plain)
                        .opacity(categoryName.isEmpty ? 0 : 1)
                        .scaleEffect(categoryName.isEmpty ? 0.001 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: categoryName.isEmpty)
                        .disabled(categoryName.isEmpty)
                    }
                    .contentShape(Rectangle())
                    
                    // Icon Selection
                    Button {
                        showingIconSelection = true
                    } label: {
                        HStack {
                            Image(selectedIcon)
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.primary)
                            
                            Text("icon".localized)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image("chevron.right")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.mainRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainGroupBackground)
            .navigationTitle(navigationTitle)
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
        .sheet(isPresented: $showingIconSelection) {
            CategoryIconSelectionView(selectedIcon: $selectedIcon)
        }
    }
    
    // MARK: - Actions
    
    private func save() {
        isCategoryNameFocused = false
        
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
            isCategoryNameFocused = true
        }
    }
}
