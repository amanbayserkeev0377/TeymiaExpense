import SwiftUI
import StoreKit

// MARK: - Tips View
struct TipsView: View {
    @State private var tipsManager = TipsManager()
    
    var body: some View {
        if tipsManager.isLoading {
            LoadingView(tint: Color.mint, lineWidth: 4)
                .frame(width: 30, height: 30)
        } else {
            ScrollView {
                VStack(spacing: 40) {
                    // Info Section
                    InfoSection()
                    
                    // Tips Grid
                    TipsGrid(tipsManager: tipsManager)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
            .toolbar {
                CloseToolbarButton()
            }
            .scrollIndicators(.hidden)
            .overlay {
                if tipsManager.showThankYou {
                    ThankYouOverlay(
                        tip: tipsManager.lastPurchasedTip,
                        isShowing: $tipsManager.showThankYou
                    )
                    .transition(.opacity.combined(with: .scale(0.8)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: tipsManager.showThankYou)
        }
    }
}

// MARK: - Info Section
struct InfoSection: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("app_icon_main")
                .resizable()
                .frame(width: 70, height: 70)
            
            VStack(spacing: 16) {
                Text("tips_title".localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Text("tips_description".localized)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
        }
    }
}

// MARK: - Tips Grid
struct TipsGrid: View {
    let tipsManager: TipsManager
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(Tip.allTips) { tip in
                if let product = tipsManager.product(for: tip) {
                    TipCard(
                        tip: tip,
                        product: product,
                        isPurchasing: tipsManager.isPurchasing
                    ) {
                        _ = await tipsManager.purchaseTip(product)
                    }
                }
            }
        }
    }
}

// MARK: - Tip Card
struct TipCard: View {
    let tip: Tip
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await onPurchase()
            }
        } label: {
            HStack(spacing: 16) {
                Image(tip.image)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(tip.name)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                    
                    
                    Text(tip.message)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                // Price
                if isPurchasing {
                    LoadingView(tint: .primary, lineWidth: 4)
                        .frame(width: 30, height: 30)
                } else {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .fontDesign(.monospaced)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.secondary.opacity(0.06))
            }
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var tint: Color
    var lineWidth: CGFloat = 4
    /// View Properties
    @State private var rotation: Double = 0
    @State private var extraRotation: Double = 0
    @State private var isAnimatedTriggered: Bool = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.3), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(tint, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.init(degrees: rotation))
                .rotationEffect(.init(degrees: extraRotation))
        }
        .compositingGroup()
        .onAppear(perform: animate)
    }
    
    private func animate() {
        guard !isAnimatedTriggered else { return }
        isAnimatedTriggered = true
        
        withAnimation(.linear(duration: 0.7).speed(1.2).repeatForever(autoreverses: false)) {
            rotation += 360
        }
        
        withAnimation(.linear(duration: 1).speed(1.2).delay(1).repeatForever(autoreverses: false)) {
            extraRotation += 360
        }
    }
}

// MARK: - Thank You Overlay
struct ThankYouOverlay: View {
    let tip: Tip?
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            // Thank you card
            VStack(spacing: 20) {
                Image(tip?.image ?? "tip.fallback")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 8) {
                    Text("thanks".localized)
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                    
                    Text("thanks_title".localized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    withAnimation {
                        isShowing = false
                    }
                } label: {
                    Text("continue".localized)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1)))
                        )
                }
            }
            .padding(30)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.secondary.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .strokeBorder(
                        LinearGradient(colors: [
                            .white.opacity(0.6),
                            .primary.opacity(0.05),
                            .primary.opacity(0.05),
                            .white.opacity(0.6)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.2
                    )
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    TipsView()
}

#Preview {
    @Previewable @State var tipsManager = TipsManager()
    ThankYouOverlay(
        tip: tipsManager.lastPurchasedTip,
        isShowing: $tipsManager.showThankYou
    )
}
