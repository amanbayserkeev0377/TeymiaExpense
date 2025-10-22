import SwiftUI

// MARK: - Tab Item Definition

enum AppTab: String, CaseIterable {
    case home = "Home"
    case overview = "Overview"
    case settings = "Settings"
    
    var symbol: String {
        switch self {
        case .home:
            return "home.fill"
        case .overview:
            return "overview.fill"
        case .settings:
            return "settings.fill"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

// MARK: - Custom Tab Bar (iOS 17-18)

struct CustomTabBar: View {
    @Environment(AppColorManager.self) private var colorManager
    @Binding var activeTab: AppTab
    
    // View Properties
    @GestureState private var isActive: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragOffset: CGFloat?
    
    private let tabItemWidth: CGFloat = 90
    private let tabItemHeight: CGFloat = 54
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.rawValue) { tab in
                    TabItemView(tab: tab)
                }
            }
            .background(alignment: .leading) {
                ZStack {
                    Capsule(style: .continuous)
                        .stroke(.gray.opacity(0.1), lineWidth: 1)
                        .opacity(isActive ? 0.5 : 0)
                    
                    Capsule(style: .continuous)
                        .fill(.gray.opacity(0.1))
                }
                .compositingGroup()
                .frame(width: tabItemWidth, height: tabItemHeight)
                .scaleEffect(isActive ? 1.3 : 1)
                .offset(x: dragOffset)
            }
            .padding(4)
            .background(TabBarBackground())
            
            Spacer()
        }
        .frame(height: 54)
        .padding(.horizontal, 26)
        .padding(.bottom, -10)
        .animation(.bouncy, value: dragOffset)
        .animation(.bouncy, value: isActive)
        .animation(.smooth, value: activeTab)
        .onAppear {
            dragOffset = CGFloat(activeTab.index) * tabItemWidth
        }
    }
    
    // MARK: - Tab Item View
    
    @ViewBuilder
    private func TabItemView(tab: AppTab) -> some View {
        let tabs = AppTab.allCases
        let tabCount = tabs.count - 1
        
        VStack(spacing: 4) {
            Image(tab.symbol)
            
            Text(tab.rawValue)
                .font(.caption2)
                .fontDesign(.rounded)
                .lineLimit(1)
        }
        .foregroundStyle(activeTab == tab ? colorManager.currentTintColor : Color.primary)
        .frame(width: tabItemWidth, height: tabItemHeight)
        .contentShape(.capsule)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isActive) { _, out, _ in
                    out = true
                }
                .onChanged { value in
                    let xOffset = value.translation.width
                    if let lastDragOffset {
                        let newDragOffset = xOffset + lastDragOffset
                        dragOffset = max(min(newDragOffset, CGFloat(tabCount) * tabItemWidth), 0)
                    } else {
                        lastDragOffset = dragOffset
                    }
                }
                .onEnded { _ in
                    lastDragOffset = nil
                    let landingIndex = Int((dragOffset / tabItemWidth).rounded())
                    if tabs.indices.contains(landingIndex) {
                        dragOffset = CGFloat(landingIndex) * tabItemWidth
                        activeTab = tabs[landingIndex]
                    }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    activeTab = tab
                    dragOffset = CGFloat(tab.index) * tabItemWidth
                }
        )
    }
    
    // MARK: - Tab Bar Background
    
    @ViewBuilder
    private func TabBarBackground() -> some View {
        ZStack {
            Capsule(style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [
                        .white.opacity(0.3),
                        .white.opacity(0.15),
                        .white.opacity(0.15),
                        .white.opacity(0.3)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 0.4
                )
        }
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 2, opaque: true)
                .background(Color.mainRowBackground.opacity(0.8))
                .clipShape(Capsule(style: .continuous))
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.15), radius: 10)
    }
}
