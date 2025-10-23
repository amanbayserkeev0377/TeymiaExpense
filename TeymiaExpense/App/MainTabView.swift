import SwiftUI

struct MainTabView: View {
    @Environment(AppColorManager.self) private var colorManager
    @State private var activeTab: AppTab = .home
    
    var body: some View {
        if #available(iOS 26, *) {
            // Native TabView for iOS 26+
            nativeTabView
        } else {
            // Custom TabBar for iOS 17-18
            customTabView
        }
    }
    
    // MARK: - Native TabView (iOS 26+)
    
    @available(iOS 26, *)
    private var nativeTabView: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("home.fill")
                    Text("home".localized)
                }
                .fontDesign(.rounded)
                .tag(0)
            
            OverviewView()
                .tabItem {
                    Image("overview.fill")
                    Text("overview".localized)
                }
                .fontDesign(.rounded)
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image("settings.fill")
                    Text("settings".localized)
                }
                .fontDesign(.rounded)
                .tag(2)
        }
        .tint(colorManager.currentTintColor)
    }
    
    // MARK: - Custom TabView (iOS 17-18)
    
    private var customTabView: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch activeTab {
                case .home:
                    HomeView()
                case .overview:
                    OverviewView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(activeTab: $activeTab)
                .padding(.bottom, -5)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
