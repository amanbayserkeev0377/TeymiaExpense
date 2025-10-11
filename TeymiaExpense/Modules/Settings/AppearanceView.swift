import SwiftUI

struct AppearanceRowView: View {
    
    var body: some View {
        ZStack {
            NavigationLink(destination: AppearanceView()) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Label(
                    title: { Text("Appearance") },
                    icon: {
                        Image("palette")
                            .resizable()
                            .frame(width: 20, height: 20)
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

struct AppearanceView: View {
    @Environment(AppColorManager.self) private var colorManager
    @Environment(AppIconManager.self) private var iconManager
    
    var body: some View {
        Form {
            Section("App Icon") {
                AppIconGridView(
                    selectedIcon: iconManager.currentIcon,
                    onIconSelected: { icon in
                        iconManager.setAppIcon(icon)
                    }
                )
            }
            .listRowBackground(Color.mainRowBackground)
            
            Section("App Color") {
                ColorPickerSection()
            }
            .listRowBackground(Color.mainRowBackground)
        }
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
        .tint(colorManager.currentColor)
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

struct ColorPickerSection: View {
    @Environment(AppColorManager.self) private var colorManager
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<AccountColors.colors.count, id: \.self) { index in
                ColorButton(
                    color: AccountColors.color(at: index),
                    isSelected: colorManager.selectedColorIndex == index,
                    onTap: {
                        colorManager.selectedColorIndex = index
                    }
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    private let buttonSize: CGFloat = 32
    private let spacing: CGFloat = 12
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    private let buttonSize: CGFloat = 32
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: buttonSize, height: buttonSize)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: buttonSize - 4, height: buttonSize - 4)
                    
                    Circle()
                        .stroke(color, lineWidth: 1)
                        .frame(width: buttonSize - 2, height: buttonSize - 2)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
