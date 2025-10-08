import SwiftUI

// MARK: - First Launch Manager
class FirstLaunchManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool
    
    private let userDefaults = UserDefaults.standard
    private let firstLaunchKey = "hasSeenOnboarding"
    
    init() {
        self.shouldShowOnboarding = !userDefaults.bool(forKey: firstLaunchKey)
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: firstLaunchKey)
        shouldShowOnboarding = false
    }
}

// MARK: - OnBoarding Card Model
struct OnBoardingCard: Identifiable {
    var id: String = UUID().uuidString
    var symbol: String
    var title: String
    var subTitle: String
}

// MARK: - OnBoarding Card Result Builder
@resultBuilder
struct OnBoardingCardResultBuilder {
    static func buildBlock(_ components: OnBoardingCard...) -> [OnBoardingCard] {
        components.compactMap { $0 }
    }
}

// MARK: - Main OnBoarding View
struct OnBoardingView<Icon: View, Footer: View>: View {
    var tint: Color
    var title: String
    var icon: Icon
    var cards: [OnBoardingCard]
    var footer: Footer
    var onContinue: () -> ()
    
    @State private var animateIcon: Bool = false
    @State private var animateTitle: Bool = false
    @State private var animateCards: [Bool]
    @State private var animateFooter: Bool = false
    
    init(
        tint: Color,
        title: String,
        @ViewBuilder icon: @escaping () -> Icon,
        @OnBoardingCardResultBuilder cards: @escaping () -> [OnBoardingCard],
        @ViewBuilder footer: @escaping () -> Footer,
        onContinue: @escaping () -> Void
    ) {
        self.tint = tint
        self.title = title
        self.icon = icon()
        self.cards = cards()
        self.footer = footer()
        self.onContinue = onContinue
        self._animateCards = .init(initialValue: Array(repeating: false, count: cards().count))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    icon
                        .frame(maxWidth: .infinity)
                        .blurSlide(animateIcon)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .blurSlide(animateTitle)
                        .padding(.bottom, 32)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        CardsView()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            
            VStack(spacing: 0) {
                footer
                    .padding(.horizontal, 20)
                
                Button(action: onContinue) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .tint(tint)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .blurSlide(animateFooter)
        }
        .frame(maxWidth: 330)
        .interactiveDismissDisabled()
        .allowsHitTesting(animateFooter)
        .task {
            guard !animateIcon else { return }
            
            await delayedAnimation(0.35) {
                animateIcon = true
            }
            
            await delayedAnimation(0.2) {
                animateTitle = true
            }
            
            try? await Task.sleep(for: .seconds(0.2))
            
            for index in animateCards.indices {
                let delay = Double(index) * 0.1
                await delayedAnimation(delay) {
                    animateCards[index] = true
                }
            }
            
            await delayedAnimation(0.2) {
                animateFooter = true
            }
        }
    }
    
    @ViewBuilder
    func CardsView() -> some View {
        ForEach(cards.indices, id: \.self) { index in
            let card = cards[index]
            
            HStack(alignment: .center, spacing: 12) {
                Image(card.symbol)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(tint)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .lineLimit(1)
                    
                    Text(card.subTitle)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .lineLimit(2)
                }
            }
            .blurSlide(animateCards[index])
        }
    }
    
    func delayedAnimation(_ delay: Double, action: @escaping () -> ()) async {
        try? await Task.sleep(for: .seconds(delay))
        withAnimation(.smooth) {
            action()
        }
    }
}

// MARK: - Teymia Expense OnBoarding
struct TeymiaOnBoardingView: View {
    let onComplete: () -> Void
    
    var body: some View {
        OnBoardingView(
            tint: AccountColors.color(at: 0),
            title: "Welcome to Teymia Expense"
        ) {
            // App Icon с закруглением
            Image("app_icon_main")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .frame(height: 180)
        } cards: {
            OnBoardingCard(
                symbol: "category.management",
                title: "Stay Organized",
                subTitle: "Categorize expenses and see where your money goes"
            )
            
            OnBoardingCard(
                symbol: "cards.blank",
                title: "Multiple Accounts",
                subTitle: "Manage all your accounts in one place"
            )
            
            OnBoardingCard(
                symbol: "bitcoin.symbol",
                title: "Multi-Currency Support",
                subTitle: "Track expenses in 200+ fiat and crypto currencies"
            )
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Image("user.shield")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(AccountColors.color(at: 0))
                
                Text("Your financial data stays on your device and is never shared.")
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 15)
        } onContinue: {
            onComplete()
        }
    }
}

// MARK: - View Extension
extension View {
    @ViewBuilder
    func blurSlide(_ show: Bool) -> some View {
        self
            .compositingGroup()
            .blur(radius: show ? 0 : 10)
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 100)
    }
}
