import SwiftUI
import SwiftData

// MARK: - Category Group Row View
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
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(category.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(.secondary)
            
            Text(category.name)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Category Action Row (with swipe actions and tap)
struct CategoryActionRow: View {
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        CategoryRowView(category: category)
            .contentShape(Rectangle())
            .onTapGesture(perform: onEdit)
            .swipeActions {
                Button(role: .destructive, action: onDelete) {
                    Image("trash.swipe")
                }
                .tint(.red)
                
                Button(action: onEdit) {
                    Image("edit")
                }
                .tint(.gray)
            }
    }
}

// MARK: - Category Navigation Row (for navigation links)
struct CategoryGroupNavigationRow: View {
    let group: CategoryGroup
    let isEditModeActive: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink {
            CategoryGroupDetailView(categoryGroup: group)
        } label: {
            CategoryGroupRowView(group: group)
        }
        .disabled(isEditModeActive)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Image("trash.swipe")
            }
            .tint(.red)
            
            Button(action: onEdit) {
                Image("edit")
            }
            .tint(.gray)
        }
    }
}
