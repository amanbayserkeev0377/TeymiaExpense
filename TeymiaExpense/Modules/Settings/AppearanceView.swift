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
                AppTintColorPickerSection()
            }
            .listRowBackground(Color.mainRowBackground)
        }
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
        .tint(colorManager.currentTintColor)
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
                AppIconButton(
                    icon: icon,
                    isSelected: selectedIcon == icon,
                    onTap: { onIconSelected(icon) }
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
            // Display actual app icon from Icon Composer file
            // System automatically renders the icon from the bundle
            IconPreviewView(iconName: icon.rawValue)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 13.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 13.5)
                        .stroke(
                            isSelected ? Color.appTint : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2.5 : 0.5
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

/// Preview view for app icon using the actual icon from bundle
struct IconPreviewView: View {
    let iconName: String
    
    var body: some View {
        // Try to load the icon image from bundle
        if let image = loadIconImage() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            // Fallback to placeholder
            RoundedRectangle(cornerRadius: 13.5)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "app.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                )
        }
    }
    
    /// Load icon image from app bundle
    private func loadIconImage() -> UIImage? {
        // Icon Composer files are stored in bundle root
        // We need to extract the 60x60 @2x or @3x image for preview
        
        // Try different icon sizes commonly used in Icon Composer
        let sizes = ["60x60@2x", "60x60@3x", "76x76@2x"]
        
        for size in sizes {
            if let path = Bundle.main.path(forResource: iconName, ofType: "png", inDirectory: size),
               let image = UIImage(contentsOfFile: path) {
                return image
            }
        }
        
        // Fallback: try to load from Assets if still there
        return UIImage(named: iconName)
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
