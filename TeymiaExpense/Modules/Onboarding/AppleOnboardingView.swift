import SwiftUI

/// OnBoarding Card
struct AppleOnBoardingCard: Identifiable {
    var id: String = UUID().uuidString
    var symbol: String
    var title: String
    var subTitle: String
}

/// OnBoarding Card Result Builder
@resultBuilder
struct OnBoardingCardResultBuilder {
    static func buildBlock(_ components: AppleOnBoardingCard...) -> [AppleOnBoardingCard] {
        components.compactMap { $0 }
    }
}

struct AppleOnBoardingView<Icon: View, Footer: View>: View {
    var tint: Color
    var title: String
    var icon: Icon
    var cards: [AppleOnBoardingCard]
    var footer: Footer
    var onContinue: () -> ()
    
    init(
        tint: Color,
        title: String,
        @ViewBuilder icon: @escaping () -> Icon,
        @OnBoardingCardResultBuilder cards: @escaping () -> [AppleOnBoardingCard],
        @ViewBuilder footer: @escaping () -> Footer,
        onContinue: @escaping () -> Void
    ) {
        self.tint = tint
        self.title = title
        self.icon = icon()
        self.cards = cards()
        self.footer = footer()
        self.onContinue = onContinue
        
        /// Setting up the array count to match up with the card count
        self._animateCards = .init(initialValue: Array(repeating: false, count: self.cards.count))
    }
    
    /// View Properties
    @State private var animateIcon: Bool = false
    @State private var animateTitle: Bool = false
    @State private var animateCards: [Bool]
    @State private var animateFooter: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    icon
                        .frame(maxWidth: .infinity)
                        .blurSlide(animateIcon)
                    
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .blurSlide(animateTitle)
                    
                    CardsView()
                        .padding(.top, 20)
                }
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            
            VStack(spacing: 0) {
                footer
                
                /// Continue Button
                Button(action: onContinue) {
                    Text("continue".localized)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primaryInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .tint(tint)
                .adaptiveButtonStyle()
                .padding(.bottom, 20)
            }
            .blurSlide(animateFooter)
        }
        .fontDesign(.rounded)
        .interactiveDismissDisabled()
        /// Disabling interaction until footer is animated
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
        .padding(.horizontal, 25)
    }
    
    /// Cards View
    @ViewBuilder
    func CardsView() -> some View {
        Group {
            /// Index will be used later for animation Effects!
            ForEach(cards.indices, id: \.self) { index in
                let card = cards[index]
                
                HStack(alignment: .top, spacing: 12) {
                    Image(card.symbol)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(tint)
                        .offset(y: 10)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text(card.subTitle)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                }
                .blurSlide(animateCards[index])
            }
        }
    }
    
    func delayedAnimation(_ delay: Double, action: @escaping () -> ()) async {
        try? await Task.sleep(for: .seconds(delay))
        
        withAnimation(.smooth) {
            action()
        }
    }
}

extension View {
    /// Custom Blur Slide Effect
    @ViewBuilder
    func blurSlide(_ show: Bool) -> some View {
        self
            /// Groups the view and adds blur to the grouped view rather than applying blur to each node view!
            .compositingGroup()
            .blur(radius: show ? 0 : 10)
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 100)
    }
}
