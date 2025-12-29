import SwiftUI

struct AppearanceSection: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system

    var body: some View {
        List {
            Section {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeMode = mode
                        }
                    } label: {
                        HStack {
                            Label {
                                Text(mode.title)
                            } icon: {
                                Image(systemName: mode.iconName)
                                    .settingsIcon(color: mode.iconColor)
                            }
                            
                            Spacer()
                            
                            if themeMode == mode {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("appearance_mode".localized)
            }
        }
        .navigationTitle("appearance".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ThemeMode {
    var title: String {
        switch self {
        case .system: return "appearance_system".localized
        case .light: return "appearance_light".localized
        case .dark: return "appearance_dark".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .system: return .gray
        case .light: return .orange
        case .dark: return .indigo
        }
    }
}
