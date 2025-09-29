import SwiftUI

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
