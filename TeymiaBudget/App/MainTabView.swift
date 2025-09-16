import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image("home.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            BudgetView()
                .tabItem {
                    Image("budget.fill")
                    Text("Budget")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image("settings.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(AccountColors.color(at: 0))
    }
}
