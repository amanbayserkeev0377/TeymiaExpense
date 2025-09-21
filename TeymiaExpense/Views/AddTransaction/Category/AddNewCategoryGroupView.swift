import SwiftUI
import SwiftData

struct AddNewCategoryGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categoryGroups: [CategoryGroup]
    
    @State private var groupName: String = ""
    @State private var selectedIcon: String = "other"
    @State private var groupType: GroupType = .expense
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $groupType) {
                        Text("Expense").tag(GroupType.expense)
                        Text("Income").tag(GroupType.income)
                    }
                    .pickerStyle(.segmented)
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
                }
            }
            .navigationTitle("New Group")
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
                        saveGroup()
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
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Helper Methods
    private func saveGroup() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sortOrder = categoryGroups.filter { $0.type == groupType }.count
        
        let newGroup = CategoryGroup(
            name: trimmedName,
            iconName: selectedIcon,
            type: groupType,
            sortOrder: sortOrder,
            isDefault: false
        )
        
        modelContext.insert(newGroup)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving category group: \(error)")
        }
    }
}
