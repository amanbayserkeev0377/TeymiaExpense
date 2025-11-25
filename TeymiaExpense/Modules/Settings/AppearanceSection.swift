import SwiftUI

struct ThemeOption {
    let name: String
    let iconName: String
    
    static let system = ThemeOption(name: "appearance_system".localized, iconName: "circle.half")
    static let light = ThemeOption(name: "appearance_light".localized, iconName: "sun")
    static let dark = ThemeOption(name: "appearance_dark".localized, iconName: "moon")
    
    static let allOptions = [system, light, dark]
}

struct AppearanceSection: View {
    @Environment(AppColorManager.self) private var colorManager
    @Environment(AppIconManager.self) private var iconManager
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @State private var currentIcon: AppIcon = .main
    
    
    var body: some View {
        Form {
            Section {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeMode = mode
                        }
                    } label: {
                        HStack {
                            Label(
                                title: { Text(ThemeOption.allOptions[mode.rawValue].name) },
                                icon: {
                                    Image(ThemeOption.allOptions[mode.rawValue].iconName)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(Color.primary)
                                }
                            )
                            Spacer()
                            Image("check")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .tint(.appTint)
                                .opacity(themeMode == mode ? 1 : 0)
                                .animation(.easeInOut, value: themeMode == mode)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("appearance_mode".localized)
            }
            .listRowBackground(Color.mainRowBackground)
            
            // App Color Section
            Section {
                AppTintColorPickerSection()
            } header: {
                Text("app_color".localized)
            }
            .listRowBackground(Color.mainRowBackground)
            
            // App Icon Section
            Section {
                AppIconGridView(
                    selectedIcon: iconManager.currentIcon,
                    onIconSelected: { icon in
                        iconManager.setAppIcon(icon)
                    }
                )
            } header: {
                Text("app_icon".localized)
            }
            .listRowBackground(Color.mainRowBackground)
        }
        .scrollContentBackground(.hidden)
        .background(Color.mainGroupBackground)
        .navigationTitle("appearance".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            currentIcon = iconManager.currentIcon
        }
        
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
        .padding(.vertical, 8)
    }
}

struct AppIconCell: View {
    let icon: AppIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    private let iconSize: CGFloat = 60
    
    var body: some View {
        Button(action: onTap) {
            Image(icon.previewImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.appTint : Color.clear,
                            lineWidth: 1.5
                        )
                        .frame(width: iconSize * 1.05, height: iconSize * 1.05)
                )
        }
        .buttonStyle(.plain)
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
