import SwiftUI

struct MainTabView: View {
    @Environment(AppColorManager.self) private var colorManager
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image("home.fill")
                Text("home".localized)
            }
            .fontDesign(.rounded)
            
            NavigationStack {
                BalanceView()
            }
            .tabItem {
                Image("balance.fill")
                Text("balance".localized)
            }
            .fontDesign(.rounded)
            
            NavigationStack {
                OverviewView()
            }
            .tabItem {
                Image("overview.fill")
                Text("overview".localized)
            }
            .fontDesign(.rounded)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image("settings.fill")
                Text("settings".localized)
            }
            .fontDesign(.rounded)
        }
        .preferredColorScheme(themeMode.colorScheme)
        .tint(colorManager.currentTintColor)
    }
}

enum ThemeMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
