import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query private var categoryGroups: [CategoryGroup]
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: GroupType = .expense
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCategoryGroups, id: \.id) { group in
                    DisclosureGroup {
                        let groupCategories = categoriesForGroup(group)
                        
                        if groupCategories.isEmpty {
                            // Empty state for group
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundStyle(.secondary)
                                Text("No categories yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 8)
                        } else {
                            // Categories in this group
                            ForEach(groupCategories, id: \.id) { category in
                                CategoryRowView(category: category)
                            }
                            .onDelete { indexSet in
                                deleteCategories(in: group, at: indexSet)
                            }
                        }
                    } label: {
                        CategoryGroupRowView(group: group)
                    }
                }
                .onDelete(perform: deleteGroups)
                .onMove(perform: moveGroups)
            }
            .navigationTitle("Manage Categories")
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
                
                ToolbarItem(placement: .principal) {
                    Picker("Category Type", selection: $selectedType) {
                        Text("Expense").tag(GroupType.expense)
                        Text("Income").tag(GroupType.income)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredCategoryGroups: [CategoryGroup] {
        categoryGroups
            .filter { $0.type == selectedType }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func categoriesForGroup(_ group: CategoryGroup) -> [Category] {
        categories
            .filter { $0.categoryGroup.id == group.id }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Helper Methods
    
    private func deleteGroups(at indexSet: IndexSet) {
        withAnimation {
            for index in indexSet {
                let group = filteredCategoryGroups[index]
                modelContext.delete(group)
            }
            try? modelContext.save()
        }
    }
    
    private func deleteCategories(in group: CategoryGroup, at indexSet: IndexSet) {
        withAnimation {
            let groupCategories = categoriesForGroup(group)
            for index in indexSet {
                let category = groupCategories[index]
                modelContext.delete(category)
            }
            try? modelContext.save()
        }
    }
    
    private func moveGroups(from source: IndexSet, to destination: Int) {
        var groups = filteredCategoryGroups
        groups.move(fromOffsets: source, toOffset: destination)
        
        for (index, group) in groups.enumerated() {
            group.sortOrder = index
        }
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct CategoryGroupRowView: View {
    let group: CategoryGroup
    
    var body: some View {
        HStack(spacing: 12) {
            Image(group.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("\(group.categories.count) categories")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(category.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundStyle(.secondary)
            
            Text(category.name)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.vertical, 1)
        .padding(.leading, 8)
    }
}
