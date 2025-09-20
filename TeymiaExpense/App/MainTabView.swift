import SwiftUI

struct MainTabView: View {
    @Namespace private var animation
    @State private var showingAddTransaction = false
    
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
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            FloatingAddButton {
                showingAddTransaction = true
            }
            .matchedTransitionSource(id: "AddTransaction", in: animation)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDragIndicator(.visible)
                .navigationTransition(.zoom(sourceID: "AddTransaction", in: animation))
        }
    }
}
