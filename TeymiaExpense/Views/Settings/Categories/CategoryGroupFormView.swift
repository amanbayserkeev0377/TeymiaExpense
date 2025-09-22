import SwiftUI
import SwiftData

struct CategoryGroupFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categoryGroups: [CategoryGroup]
    
    let editingGroup: CategoryGroup? // nil = add new, value = edit existing
    
    @State private var groupName: String = ""
    @State private var selectedIcon: String = "other"
    @State private var groupType: GroupType = .expense
    @State private var showingIconSelection = false
    
    init(editingGroup: CategoryGroup? = nil) {
        self.editingGroup = editingGroup
    }
    
    private var isEditing: Bool {
        editingGroup != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $groupType) {
                        Text("Expense").tag(GroupType.expense)
                        Text("Income").tag(GroupType.income)
                    }
                    .pickerStyle(.segmented)
                    .disabled(isEditing) // Don't allow type change when editing
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Group Name", text: $groupName)
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
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(isEditing ? "Edit Group" : "New Group")
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
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            setupInitialValues()
        }
        .sheet(isPresented: $showingIconSelection) {
            CategoryIconSelectionView(selectedIcon: $selectedIcon)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Helper Methods
    private func setupInitialValues() {
        if let group = editingGroup {
            // Edit mode - populate with existing values
            groupName = group.name
            selectedIcon = group.iconName
            groupType = group.type
        }
        // Add mode uses default values from @State initialization
    }
    
    private func save() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingGroup = editingGroup {
            // Update existing group
            existingGroup.name = trimmedName
            existingGroup.iconName = selectedIcon
            // Don't change type when editing
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
