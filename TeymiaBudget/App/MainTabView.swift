import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    BudgetView()
                case 2:
                    SettingsView()
                default:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            TabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            // Overview Tab
            CustomTabButton(
                title: "Dashboard",
                iconName: "home.fill",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            // Budget Tab
            CustomTabButton(
                title: "Budget",
                iconName: "budget.fill",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            // Settings Tab
            CustomTabButton(
                title: "Settings",
                iconName: "settings.fill",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial
                .shadow(.drop(color: .black.opacity(0.15), radius: 10, x: 0, y: 5))
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}

struct CustomTabButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    @State private var animateTap = false
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                animateTap = true
            } completion: {
                withAnimation(.easeOut(duration: 0.15)) {
                    animateTap = false
                }
            }
        }) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .foregroundStyle(isSelected ? .app : .secondary)
                    .frame(width: 24, height: 24)
                    .scaleEffect(animateTap ? 1.1 : 1.0)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? .app : .secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
