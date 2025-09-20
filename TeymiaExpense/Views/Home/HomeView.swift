import SwiftUI
import SwiftData

struct HomeView: View {
    @Namespace private var animation
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var accounts: [Account]
    @StateObject private var firstLaunchManager = FirstLaunchManager()
    
    @State private var showingAddTransaction = false
    @State private var showingAddAccount = false
    
    // View Properties
    @State private var topInset: CGFloat = 0
    @State private var scrollOffsetY: CGFloat = 0
    @State private var scrollProgressX: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 15) {
                        HeaderView()
                        
                        CarouselView()
                            .zIndex(-1)
                    }
                }
                .safeAreaPadding(15)
                .background {
                    Rectangle()
                        .fill(colorScheme == .light ? Color.white.gradient : Color.black.gradient)
                        .scaleEffect(y: -1)
                        .ignoresSafeArea()
                }
                .onScrollGeometryChange(for: ScrollGeometry.self) {
                    $0
                } action: { oldValue, newValue in
                    topInset = newValue.contentInsets.top + 100
                    scrollOffsetY = newValue.contentOffset.y + newValue.contentInsets.top
                }
            }
            
            FloatingAddButton {
                showingAddTransaction = true
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $firstLaunchManager.shouldShowOnboarding) {
            DrawOnSymbolEffectExample(
                tint: AccountColors.color(at: 0),
                buttonTitle: "Start Managing Money",
                data: [
                    .init(
                        name: "chart.bar.xaxis.ascending",
                        title: "Categorized Expenses",
                        subtitle: "Categorize your expenses to see\n where your money is going",
                        preDelay: 0.3
                    ),
                    .init(
                        name: "magnifyingglass.circle",
                        title: "Search for Expenses",
                        subtitle: "Search for your expenses\nby account or category",
                        preDelay: 1.6
                    ),
                    .init(
                        name: "arrow.up.arrow.down",
                        title: "Track Your Money",
                        subtitle: "Easily manage your income\nand expenses in one place",
                        preDelay: 1.2
                    ),
                ]
            ) {
                firstLaunchManager.completeOnboarding()
            }
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    func HeaderView() -> some View {
        HStack {
            Text("Total: 50 000 сом")
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
            
            Spacer(minLength: 0)
            
            Button(action: {
                showingAddAccount = true
            }) {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.clear)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Carousel View
    @ViewBuilder
    func CarouselView() -> some View {
        let spacing: CGFloat = 6
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: spacing) {
                ForEach(accounts) { account in
                    AccountCardView(account: account)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: 220)
        .background(BackdropEffect())
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .onScrollGeometryChange(for: CGFloat.self) {
            let offsetX = $0.contentOffset.x + $0.contentInsets.leading
            let width = $0.containerSize.width + spacing
            
            return offsetX / width
        } action: { oldValue, newValue in
            let maxValue = CGFloat(max(accounts.count - 1, 0))
            scrollProgressX = min(max(newValue, 0), maxValue)
        }
    }
    
    // MARK: - Backdrop Effect
    @ViewBuilder
    func BackdropEffect() -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(accounts.reversed()) { account in
                    let index = CGFloat(accounts.firstIndex(where: { $0.id == account.id }) ?? 0) + 1
                    
                    switch account.designType {
                    case .image:
                        Image(account.cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                            .opacity(index - scrollProgressX)
                        
                    case .color:
                        Rectangle()
                            .fill(AccountColors.gradient(at: account.designIndex))
                            .frame(width: size.width, height: size.height)
                            .opacity(index - scrollProgressX)
                    }
                }
            }
            .compositingGroup()
            .blur(radius: 25, opaque: true)
            .overlay {
                Rectangle()
                    .fill(.black.opacity(0.25))
            }
            .mask {
                Rectangle()
                    .fill(.linearGradient(colors: [
                        .black,
                        .black.opacity(0.7),
                        .black.opacity(0.6),
                        .black.opacity(0.3),
                        .black.opacity(0.25),
                        .clear
                    ], startPoint: .top, endPoint: .bottom))
            }
        }
        .containerRelativeFrame(.horizontal)
        .padding(.bottom, -60)
        .padding(.top, -topInset)
        .offset(y: scrollOffsetY < 0 ? scrollOffsetY : 0)
    }
}
