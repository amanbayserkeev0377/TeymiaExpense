import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            Section("Groups") {
                ForEach(categoryGroups.sorted(by: { $0.sortOrder < $1.sortOrder })) { group in
                    HStack {
                        Image(group.iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(group.name)
                        
                        Spacer()
                        
                        Text(group.type.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .onDelete(perform: deleteGroups)
                .onMove(perform: moveGroups)
            }
            
            Section("Categories") {
                ForEach(categories.sorted(by: { $0.sortOrder < $1.sortOrder })) { category in
                    HStack {
                        Image(category.iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text(category.name)
                            Text(category.categoryGroup.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .onDelete(perform: deleteCategories)
            }
        }
        .navigationBarTitle("Manage Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }
    
    private func deleteGroups(at indexSet: IndexSet) {
        let sortedGroups = categoryGroups.sorted(by: { $0.sortOrder < $1.sortOrder })
        for index in indexSet {
            let group = sortedGroups[index]
            if group.isDeletable {
                modelContext.delete(group)
            }
        }
    }
    
    private func deleteCategories(at indexSet: IndexSet) {
        let sortedCategories = categories.sorted(by: { $0.sortOrder < $1.sortOrder })
        for index in indexSet {
            let category = sortedCategories[index]
            if category.isDeletable {
                modelContext.delete(category)
            }
        }
    }
    
    private func moveGroups(from source: IndexSet, to destination: Int) {
        var sortedGroups = categoryGroups.sorted(by: { $0.sortOrder < $1.sortOrder })
        sortedGroups.move(fromOffsets: source, toOffset: destination)
        
        for (index, group) in sortedGroups.enumerated() {
            group.sortOrder = index
        }
    }
}

