import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            OverviewVIew()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("Overview")
                }
            
            BudgetView()
                .tabItem {
                    Image(systemName: "wallet.bifold")
                    Text("Budget")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}
