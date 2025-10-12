import SwiftUI
import SwiftData

struct CategoryGroupFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categoryGroups: [CategoryGroup]
    
    // MARK: - Configuration
    private let editingGroup: CategoryGroup?
    private let groupType: GroupType
    
    // MARK: - State
    @State private var groupName: String
    @State private var selectedIcon: String
    @State private var showingIconSelection = false
    
    // MARK: - Initializers
    
    /// Create form for adding new group
    init(groupType: GroupType) {
        self.editingGroup = nil
        self.groupType = groupType
        self._groupName = State(initialValue: "")
        self._selectedIcon = State(initialValue: "other")
    }
    
    /// Create form for editing existing group
    init(editingGroup: CategoryGroup) {
        self.editingGroup = editingGroup
        self.groupType = editingGroup.type
        self._groupName = State(initialValue: editingGroup.name)
        self._selectedIcon = State(initialValue: editingGroup.iconName)
    }
    
    // MARK: - Computed Properties
    
    private var isEditing: Bool {
        editingGroup != nil
    }
    
    private var navigationTitle: String {
        isEditing ? "Edit Group" : "New Group"
    }
    
    private var canSave: Bool {
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                detailsSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
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
    
    // MARK: - View Components
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Group Name", text: $groupName)
                .autocorrectionDisabled()
            
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
                    
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } header: {
            Text(groupType == .expense ? "Expense" : "Income")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(nil)
        }
        .listRowBackground(Color.mainRowBackground)
    }
    
    // MARK: - Actions
    
    private func save() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingGroup = editingGroup {
            // Update existing group
            existingGroup.name = trimmedName
            existingGroup.iconName = selectedIcon
        } else {
            // Create new group
            let sortOrder = categoryGroups.filter { $0.type == groupType }.count
            let newGroup = CategoryGroup(
                name: trimmedName,
                iconName: selectedIcon,
                type: groupType,
                sortOrder: sortOrder,
                isDefault: false
            )
            modelContext.insert(newGroup)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving category group: \(error)")
        }
    }
}
