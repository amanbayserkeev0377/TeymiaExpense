import SwiftUI

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("home.fill")
                    Text("home".localized)
                }
            
            BalanceView()
                .tabItem {
                    Image("balance.fill")
                    Text("balance".localized)
                }
            
            OverviewView()
                .tabItem {
                    Image("overview.fill")
                    Text("overview".localized)
                }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image("settings.fill")
                Text("settings".localized)
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(themeMode.colorScheme)
        .tint(.primary)
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
