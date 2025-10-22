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
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.primary)
                    }
                )
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

struct AppearanceView: View {
    @Environment(AppColorManager.self) private var colorManager
    @Environment(AppIconManager.self) private var iconManager
    
    var body: some View {
        BlurNavigationView(
            title: "Appearance",
            showBackButton: true
        ) {
            VStack(spacing: 32) {
                // App Color Section
                VStack(alignment: .leading, spacing: 12) {
                    AppTintColorPickerSection()
                        .padding()
                        .background(Color.mainRowBackground)
                        .cornerRadius(30)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 10
                        )
                        .padding(.horizontal)
                }
                
                // App Icon Section
                VStack(alignment: .leading, spacing: 12) {
                    AppIconGridView(
                        selectedIcon: iconManager.currentIcon,
                        onIconSelected: { icon in
                            iconManager.setAppIcon(icon)
                        }
                    )
                    .padding()
                    .background(Color.mainRowBackground)
                    .cornerRadius(30)
                    .shadow(
                        color: Color.black.opacity(0.15),
                        radius: 10
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color.mainBackground)
        .tint(colorManager.currentTintColor)
        .navigationBarHidden(true)
    }
}

// MARK: - App Icon Grid

struct AppIconGridView: View {
    let selectedIcon: AppIcon
    let onIconSelected: (AppIcon) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(AppIcon.allCases) { icon in
                AppIconCell(
                    icon: icon,
                    isSelected: selectedIcon == icon,
                    onTap: { onIconSelected(icon) }
                )
            }
        }
    }
}

struct AppIconCell: View {
    let icon: AppIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(icon.previewImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.appTint : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2.5 : 0.5
                        )
                )
        }
    }
}

// MARK: - App Tint Color Picker

struct AppTintColorPickerSection: View {
    @Environment(AppColorManager.self) private var colorManager
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<AppTintColor.allCases.count, id: \.self) { index in
                AppTintColorButton(
                    color: AppTintColors.color(at: index),
                    isSelected: colorManager.selectedTintColorIndex == index,
                    onTap: {
                        colorManager.selectedTintColorIndex = index
                    }
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    private let spacing: CGFloat = 12
}

struct AppTintColorButton: View {
    @Environment(\.colorScheme) private var colorScheme
    
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
                        .stroke(
                            colorScheme == .dark ? Color.black : Color.white,
                            lineWidth: 3
                        )
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
