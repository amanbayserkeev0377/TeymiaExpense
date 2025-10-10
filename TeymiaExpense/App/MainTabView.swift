import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Image("home.fill")
                        Text("Home")
                    }
                    .fontDesign(.rounded)
                    .tag(0)
                
                OverviewView()
                    .tabItem {
                        Image("overview.fill")
                        Text("Overview")
                    }
                    .fontDesign(.rounded)
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Image("settings.fill")
                        Text("Settings")
                    }
                    .fontDesign(.rounded)
                    .tag(2)
            }
            .tint(AccountColors.color(at: 0))
        }
    }
}
