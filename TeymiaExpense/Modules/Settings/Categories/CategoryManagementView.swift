import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: CategoryType
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
    
    init(initialType: CategoryType = .expense) {
        _selectedType = State(initialValue: initialType)
    }
    
    var body: some View {
        List(selection: $selectedCategories) {
            Section {
                Picker("", selection: $selectedType) {
                    Text("expense".localized).tag(CategoryType.expense)
                    Text("income".localized).tag(CategoryType.income)
                }
                .pickerStyle(.segmented)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // Categories list
            if filteredCategories.isEmpty {
                Section {
                    ContentUnavailableView(
                        "no_categories".localized,
                        systemImage: "circle.grid.2x2",
                        description: Text("no_categories_description".localized)
                    )
                }
                .listRowSeparator(.hidden)
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
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.secondary.opacity(0.07))
            }
        }
        .tint(.secondary)
        .listStyle(.plain)
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .navigationTitle("categories".localized)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(BackgroundView())
        .toolbar {
            EditDoneToolbarButton(isEditMode: $isEditMode) {
                selectedCategories = []
            }
            
            AddToolbarButton {
                showingAddCategory = true
            }
        }
        .safeAreaBar(edge: .bottom) {
            if isEditMode {
                HStack {
                    Button {
                        if selectedCategories.count < filteredCategories.count {
                            selectedCategories = Set(filteredCategories)
                        } else {
                            selectedCategories = []
                        }
                    } label: {
                        Text(selectedCategories.count < filteredCategories.count ? "select_all".localized : "deselect_all".localized)
                            .padding(4)
                            .foregroundStyle(Color.primaryInverse)
                    }
                    .buttonStyle(.glassProminent)
                    
                    Button(role: .destructive) {
                        confirmDeleteSelectedCategories()
                    } label: {
                        Text("delete_count_button_label".localized(with: selectedCategories.count))
                            .padding(4)
                    }
                    .tint(.red)
                    .buttonStyle(.glassProminent)
                    .disabled(selectedCategories.isEmpty)
                }
                .padding()
                .frame(maxWidth: .infinity)
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
        .alert("alert_delete_category".localized, isPresented: $showingDeleteAlert) {
            Button("cancel".localized, role: .cancel) {
                pendingDeleteAction = nil
            }
            Button("delete".localized, role: .destructive) {
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
                deleteAlertMessage = "category_delete_alert_single_with_txn".localized(
                    with: category.name,
                    totalTransactions
                )
            } else {
                deleteAlertMessage = "category_delete_alert_single_no_txn".localized(
                    with: category.name
                )
            }
        } else {
            if totalTransactions > 0 {
                deleteAlertMessage = "category_delete_alert_multiple_with_txn".localized(
                    with: categoriesToDelete.count,
                    totalTransactions
                )
            } else {
                deleteAlertMessage = "category_delete_alert_multiple_no_txn".localized(
                    with: categoriesToDelete.count
                )
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
