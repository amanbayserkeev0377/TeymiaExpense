import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case 0:
                    OverviewView()
                case 1:
                    BudgetView()
                case 2:
                    SettingsView()
                default:
                    OverviewView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Overview Tab
                    CustomTabButton(
                        title: "Home",
                        iconName: "home",
                        filledIconName: "home.fill",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    // Budget Tab
                    CustomTabButton(
                        title: "Budget",
                        iconName: "budget",
                        filledIconName: "budget.fill",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                    
                    // Settings Tab
                    CustomTabButton(
                        title: "Settings",
                        iconName: "settings",
                        filledIconName: "settings.fill",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 34)
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
                    .stroke(.separator, lineWidth: 0.4)
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
    let filledIconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(isSelected ? filledIconName : iconName)
                    .resizable()
                    .foregroundStyle(isSelected ? .accent : .secondary)
                    .frame(width: 24, height: 24)
                
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
