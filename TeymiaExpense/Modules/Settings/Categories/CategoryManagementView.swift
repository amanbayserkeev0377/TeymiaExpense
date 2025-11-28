import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: CategoryType = .expense
    @State private var isEditMode = false
    
    // Sheet state
    @State private var editingCategory: Category?
    @State private var showingAddCategory = false
    
    // Delete confirmation & Multiselect state
    @State private var selectedCategories: Set<Category> = []
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    
    private var showingEditCategory: Binding<Bool> {
        Binding(
            get: { editingCategory != nil },
            set: { if !$0 { editingCategory = nil } }
        )
    }
    
    private var filteredCategories: [Category] {
        categories
            .filter { $0.type == selectedType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        List(selection: $selectedCategories) {
            Section {
                Picker("Type", selection: $selectedType) {
                    Text("Expense").tag(CategoryType.expense)
                    Text("Income").tag(CategoryType.income)
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            
            // Categories list
            if filteredCategories.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No categories",
                        systemImage: "circle.grid.2x2",
                        description: Text("Tap + to add a category")
                    )
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(filteredCategories) { category in
                        CategoryRow(category: category)
                            .tag(category)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !isEditMode {
                                    editingCategory = category
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    confirmDeleteCategory(category)
                                } label: {
                                    Label("", image: "trash.swipe")
                                }
                                .tint(.red)
                            }
                    }
                    .onMove(perform: isEditMode ? moveCategories : nil)
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .scrollContentBackground(.hidden)
        .background(Color.mainGroupBackground)
        .navigationTitle("categories".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditDoneToolbarButton(isEditMode: $isEditMode) {
                selectedCategories = []
            }
            
            AddToolbarButton {
                showingAddCategory = true
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isEditMode {
                HStack {
                    Button {
                        if selectedCategories.count < filteredCategories.count {
                            selectedCategories = Set(filteredCategories)
                        } else {
                            selectedCategories = []
                        }
                    } label: {
                        Text(selectedCategories.count < filteredCategories.count ? "Select All" : "Deselect All")
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(role: .destructive) {
                        confirmDeleteSelectedCategories()
                    } label: {
                        Text("Delete (\(selectedCategories.count))")
                            .padding(4)
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedCategories.isEmpty)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 2, opaque: false)
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(categoryType: selectedType)
        }
        .sheet(isPresented: showingEditCategory) {
            if let category = editingCategory {
                CategoryFormView(editingCategory: category)
            }
        }
        .alert("Delete Category?", isPresented: $showingDeleteAlert) {
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
    
    private func deleteCategories(_ categories: [Category]) {
        withAnimation {
            categories.forEach { modelContext.delete($0) }
            try? modelContext.save()
            selectedCategories = []
        }
    }
    
    private func confirmDeleteSelectedCategories() {
        guard !selectedCategories.isEmpty else { return }
        
        let categoriesToDelete = Array(selectedCategories)
        let totalTransactions = categoriesToDelete.reduce(0) { $0 + ($1.transactions?.count ?? 0) }
        
        if categoriesToDelete.count == 1 {
            let category = categoriesToDelete.first!
            if totalTransactions > 0 {
                deleteAlertMessage = "Category \"\(category.name)\" has \(totalTransactions) transactions. They will be kept but unassigned."
            } else {
                deleteAlertMessage = "Category \"\(category.name)\" will be deleted."
            }
        } else {
            if totalTransactions > 0 {
                deleteAlertMessage = "Are you sure you want to delete \(categoriesToDelete.count) categories? They contain a total of \(totalTransactions) transactions, which will be kept but unassigned."
            } else {
                deleteAlertMessage = "Are you sure you want to delete \(categoriesToDelete.count) categories?"
            }
        }
        
        pendingDeleteAction = {
            self.deleteCategories(categoriesToDelete)
        }
        showingDeleteAlert = true
    }
    
    private func confirmDeleteCategory(_ category: Category) {
        selectedCategories = [category]
        confirmDeleteSelectedCategories()
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var cats = filteredCategories
        cats.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in cats.enumerated() {
            category.sortOrder = index
        }
        
        try? modelContext.save()
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            Image(category.iconName)
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(.primary)
            
            Text(category.name)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}
