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
    
    private var filteredCategories: [Category] {
        categories
            .filter { $0.type == selectedType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        List {
            // Type picker
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
                        systemImage: "folder",
                        description: Text("Tap + to add a category")
                    )
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(filteredCategories) { category in
                        CategoryRow(category: category)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isEditMode {
                                    editingCategory = category
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    confirmDeleteCategory(category)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    editingCategory = category
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.gray)
                            }
                    }
                    .onMove(perform: isEditMode ? moveCategories : nil)
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        .sheet(isPresented: $showingAddCategory) {
            CategoryFormView(categoryType: selectedType)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: showingEditCategory) {
            if let category = editingCategory {
                CategoryFormView(editingCategory: category)
                    .presentationDragIndicator(.visible)
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
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var cats = filteredCategories
        cats.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in cats.enumerated() {
            category.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    private func confirmDeleteCategory(_ category: Category) {
        let transactionCount = category.transactions?.count ?? 0
        if transactionCount > 0 {
            deleteAlertMessage = "This category has \(transactionCount) transactions. They will be kept but unassigned."
        } else {
            deleteAlertMessage = "This category will be deleted."
        }
        
        pendingDeleteAction = {
            withAnimation {
                modelContext.delete(category)
                try? modelContext.save()
            }
        }
        showingDeleteAlert = true
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(category.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
            
            Text(category.name)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}
