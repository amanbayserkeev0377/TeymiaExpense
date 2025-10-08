import SwiftUI

struct MainTabView: View {
    @State private var showingAddTransaction = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
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
            
            // Floating Plus Button
            FloatingPlusButton {
                showingAddTransaction = true
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDragIndicator(.visible)
        }
    }
}
