import SwiftUI

struct MainTabView: View {
    @State private var showingAddTransaction = false
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                TabViewContent()
                    .tabBarMinimizeBehavior(.onScrollDown)
                    .tabViewBottomAccessory {
                        FloatingAddButton {
                            showingAddTransaction = true
                        }
                    }
            } else {
                TabViewContent(60)
                    .overlay(alignment: .bottom) {
                        FloatingAddButton {
                            showingAddTransaction = true
                        }
                        .padding(.vertical, 8)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(.gray.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(.mainRowBackground.opacity(0.9))
                                    .padding(1.2)
                            }
                            .compositingGroup()
                        }
                        .offset(y: -52)
                        .padding(.horizontal, 15)
                    }
                    .ignoresSafeArea(.keyboard, edges: .all)
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(40)
        }
    }
    
    // MARK: - Tab View Content
    
    @ViewBuilder
    private func TabViewContent(_ safeAreaBottomPadding: CGFloat = 0) -> some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("home.fill")
                    Text("Home")
                }
                .tag(0)
                .if(safeAreaBottomPadding > 0) { view in
                    view.safeAreaPadding(.bottom, safeAreaBottomPadding)
                }
            
            OverviewView()
                .tabItem {
                    Image("overview.fill")
                    Text("Overview")
                }
                .tag(1)
                .if(safeAreaBottomPadding > 0) { view in
                    view.safeAreaPadding(.bottom, safeAreaBottomPadding)
                }
            
            SettingsView()
                .tabItem {
                    Image("settings.fill")
                    Text("Settings")
                }
                .tag(2)
                .if(safeAreaBottomPadding > 0) { view in
                    view.safeAreaPadding(.bottom, safeAreaBottomPadding)
                }
        }
        .tint(AccountColors.color(at: 0))
    }
}

// MARK: - View Extension for Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
