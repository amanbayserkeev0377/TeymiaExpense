import SwiftUI

struct MainTabView: View {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some View {
        TabView {
            Tab.init("transactions".localized, image: "transactions.fill") {
                NavigationStack {
                    TransactionsView()
                }
            }
            Tab.init("balance".localized, image: "balance.fill") {
                NavigationStack {
                    BalanceView()
                }
            }
            Tab.init("overview".localized, image: "overview.fill") {
                NavigationStack {
                    OverviewView()
                }
            }
            Tab.init("settings".localized, image: "settings.fill") {
                NavigationStack {
                    SettingsView()
                }
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
