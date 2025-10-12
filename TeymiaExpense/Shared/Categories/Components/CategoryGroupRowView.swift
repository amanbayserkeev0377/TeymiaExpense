import SwiftUI

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
                
                Text("\(group.categories?.count ?? 0) categories")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct CategoryGroupNavigationRow: View {
    let group: CategoryGroup
    let isEditModeActive: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            NavigationLink(destination: CategoryGroupDetailView(categoryGroup: group)) {
                EmptyView()
            }
            .opacity(0)
            .disabled(isEditModeActive)
            
            HStack {
                CategoryGroupRowView(group: group)
                
                Spacer()
                
                if !isEditModeActive {
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
        }
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

