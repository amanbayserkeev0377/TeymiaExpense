import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categoryGroups: [CategoryGroup]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let initialType: GroupType?
    
    @State private var selectedType: GroupType
    @State private var isEditMode = false
    
    // MARK: - Simplified sheet state
    @State private var editingGroup: CategoryGroup?
    @State private var showingAddGroup = false
    
    // Delete confirmation
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    
    // MARK: - Proper initialization
    init(initialType: GroupType? = nil) {
        self.initialType = initialType
        // Initialize selectedType immediately, not in onAppear
        self._selectedType = State(initialValue: initialType ?? .expense)
    }
    
    // Computed property for sheet binding
    private var showingEditGroup: Binding<Bool> {
        Binding(
            get: { editingGroup != nil },
            set: { if !$0 { editingGroup = nil } }
        )
    }
    
    private var filteredCategoryGroups: [CategoryGroup] {
        categoryGroups
            .filter { $0.type == selectedType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var body: some View {
        NavigationStack {
            List {
                typePickerSection
                groupsSection
            }
            .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            .scrollContentBackground(.hidden)
            .background(.mainBackground)
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            CategoryGroupFormView(groupType: selectedType)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: showingEditGroup) {
            if let group = editingGroup {
                CategoryGroupFormView(editingGroup: group)
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("Are you sure you want to delete?", isPresented: $showingDeleteAlert) {
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
    
    // MARK: - View Components
    
    @ViewBuilder
    private var typePickerSection: some View {
        Section {
            Picker("Type", selection: $selectedType) {
                Text("expense".localized).tag(GroupType.expense)
                Text("income".localized).tag(GroupType.income)
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var groupsSection: some View {
        if filteredCategoryGroups.isEmpty {
            Section {
                CategoryEmptyStateView(isGroups: true)
            }
            .listRowBackground(Color.clear)
        }
        else {
            Section {
                ForEach(filteredCategoryGroups, id: \.id) { group in
                    CategoryGroupNavigationRow(
                        group: group,
                        isEditModeActive: isEditMode,
                        onEdit: { editingGroup = group },
                        onDelete: { confirmDeleteGroup(group) }
                    )
                }
                .onMove(perform: isEditMode ? moveGroups : nil)
            } footer: {
                Text("Swipe left to edit or delete it.")
            }
            .listRowBackground(Color.mainRowBackground)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if initialType != nil {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditMode.toggle()
                }
            } label: {
                Image(systemName: isEditMode ? "checkmark" : "pencil")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingAddGroup = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func moveGroups(from source: IndexSet, to destination: Int) {
        var groups = filteredCategoryGroups
        groups.move(fromOffsets: source, toOffset: destination)
        
        for (index, group) in groups.enumerated() {
            group.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    private func confirmDeleteGroup(_ group: CategoryGroup) {
        let categoryCount = group.categories?.count ?? 0
        if categoryCount > 0 {
            deleteAlertMessage = "This will delete the group and its \(categoryCount) categories. All associated transactions will also be deleted."
        } else {
            deleteAlertMessage = "This will delete the group. All associated transactions will also be deleted."
        }
        
        pendingDeleteAction = {
            withAnimation {
                modelContext.delete(group)
                try? modelContext.save()
            }
        }
        showingDeleteAlert = true
    }
}
