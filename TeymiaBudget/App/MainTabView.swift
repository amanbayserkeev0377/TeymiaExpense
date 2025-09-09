import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    BudgetView()
                case 2:
                    SettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Home Tab
                    CustomTabButton(
                        title: "Home",
                        iconName: "home",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    // Budget Tab
                    CustomTabButton(
                        title: "Budget",
                        iconName: "budget",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                    
                    // Settings Tab
                    CustomTabButton(
                        title: "Settings",
                        iconName: "settings",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(Color(.systemBackground).opacity(0.95))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    )
                )
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    )
                    .stroke(.separator, lineWidth: 0.15)
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Custom Tab Button
struct CustomTabButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(isSelected ? .accent : .secondary)
                    .frame(width: 28, height: 28)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundStyle(isSelected ? .accent : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
