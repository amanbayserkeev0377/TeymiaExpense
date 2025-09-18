import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("home.fill")
                    Text("Home")
                }
                .tag(0)
            
            OverviewView()
                .tabItem {
                    Image("overview.fill")
                    Text("Overview")
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
