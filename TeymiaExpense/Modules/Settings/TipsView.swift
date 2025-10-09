import SwiftUI
import StoreKit

// MARK: - Tips View
struct TipsView: View {
    @State private var tipsManager = TipsManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AnimatedBlobBackground()
            
            if tipsManager.isLoading {
                LoadingView(tint: Color.mint, lineWidth: 4)
                    .frame(width: 30, height: 30)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Info Section
                        InfoSection()
                        
                        // Tips Grid
                        TipsGrid(tipsManager: tipsManager)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
        }
        .preferredColorScheme(.dark)
        .overlay {
            if tipsManager.showThankYou {
                ThankYouOverlay(
                    tip: tipsManager.lastPurchasedTip,
                    isShowing: $tipsManager.showThankYou
                )
            }
        }
    }
}

// MARK: - Info Section
struct InfoSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("plantImage")
                .resizable()
                .frame(width: 200, height: 200)
            
            VStack(spacing: 16) {
                Text("All features in Teymia Expense are free")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                
                Text("You can leave a tip to support ongoing development and future updates.")
                    .fontDesign(.rounded)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, -10)
        }
    }
}

// MARK: - Tips Grid
struct TipsGrid: View {
    let tipsManager: TipsManager
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Tip.allTips) { tip in
                if let product = tipsManager.product(for: tip) {
                    TipCard(
                        tip: tip,
                        product: product,
                        isPurchasing: tipsManager.isPurchasing
                    ) {
                        await tipsManager.purchaseTip(product)
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
                        .foregroundStyle(.white)
                    
                    Text(tip.message)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Price
                if isPurchasing {
                    LoadingView(tint: .white, lineWidth: 4)
                        .frame(width: 30, height: 30)
                } else {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.white.opacity(0.12))
            }
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [
                            .white.opacity(0.4),
                            .white.opacity(0.1),
                            .white.opacity(0.2),
                            .white.opacity(0.2)
                        ], startPoint: .topLeading, endPoint: .bottom),
                        lineWidth: 1
                    )
            }
            .shadow(color: .white.opacity(0.2), radius: 5)
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
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            // Thank you card
            VStack(spacing: 20) {
                Text(tip?.image ?? "❤️")
                    .font(.system(size: 60))
                
                VStack(spacing: 8) {
                    Text("Thank You!")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Text("Your support means the world to me!\nIt helps keep the app free for everyone.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    withAnimation {
                        isShowing = false
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1)))
                        )
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(.ultraThinMaterial.opacity(0.9))
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
    }
}

#Preview {
    TipsView()
}

//#Preview {
//    @Previewable @State var tipsManager = TipsManager()
//
//    ThankYouOverlay(
//        tip: tipsManager.lastPurchasedTip,
//        isShowing: $tipsManager.showThankYou
//    )
//}
