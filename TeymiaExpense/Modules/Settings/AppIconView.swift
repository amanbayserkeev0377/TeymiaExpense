import SwiftUI

struct AppIconRowView: View {
    
    var body: some View {
        ZStack {
            NavigationLink(destination: AppIconView()) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Label(
                    title: { Text("App Icon") },
                    icon: {
                        Image("square")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.primary)
                    }
                )
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
    }
}

struct AppIconView: View {
    @ObservedObject private var iconManager = AppIconManager.shared
    
    var body: some View {
        Form {
            Section {
                AppIconGridView(
                    selectedIcon: iconManager.currentIcon,
                    onIconSelected: { icon in
                        iconManager.setAppIcon(icon)
                    }
                )
            }
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AppIconGridView: View {
    let selectedIcon: AppIcon
    let onIconSelected: (AppIcon) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(AppIcon.allIcons) { icon in
                AppIconButton(
                    icon: icon,
                    isSelected: selectedIcon == icon,
                    onTap: {
                        onIconSelected(icon)
                    }
                )
            }
        }
        .padding(.vertical, 8)
    }
}

struct AppIconButton: View {
    let icon: AppIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(icon.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? .gray : .gray.opacity(0.3),
                               lineWidth: isSelected ? 2 : 0.3)
                )
        }
        .buttonStyle(.plain)
    }
}
