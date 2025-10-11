import SwiftUI
import StoreKit

struct TipsRowView: View {
    @State private var showingTips = false
    
    var body: some View {
        Section {
            Button {
                showingTips = true
            } label: {
                HStack {
                    Label(
                        title: {
                            Text("Buy me a matcha")
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1)),
                                            Color(#colorLiteral(red: 0.1098020747, green: 0.6508788466, blue: 0.6040038466, alpha: 1))
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        },
                        icon: {
                            Image("gift.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(#colorLiteral(red: 0.4470213652, green: 1, blue: 0.6704101562, alpha: 1)),
                                            Color(#colorLiteral(red: 0.1098020747, green: 0.6508788466, blue: 0.6040038466, alpha: 1))
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    )
                    
                    Spacer()
                    
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Color.mainRowBackground)
        .fullScreenSheet(ignoresSafeArea: true, isPresented: $showingTips) { safeArea in
            TipsView()
                .safeAreaPadding(.top, safeArea.top + 35)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.secondary)
                        .frame(width: 45, height: 5)
                        .frame(maxWidth: .infinity)
                        .frame(height: safeArea.top + 30, alignment: .bottom)
                        .offset(y: -10)
                        .contentShape(.rect)
                }
                .clipShape(Background())
        } background: {
            Color.clear
        }
    }
    
    func Background() -> some Shape {
        if #available(iOS 26, *) {
            return ConcentricRectangle(corners: .concentric, isUniform: true)
        } else {
            return RoundedRectangle(cornerRadius: 30)
        }
    }
}

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
                    VStack(spacing: 40) {
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
                .transition(.opacity.combined(with: .scale(0.8)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: tipsManager.showThankYou)
    }
}

// MARK: - Info Section
struct InfoSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("plant.image")
                .resizable()
                .frame(width: 200, height: 200)
            
            VStack(spacing: 16) {
                Text("All features in Teymia Expense are free")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3)
                
                Text("You can leave a tip to support ongoing development and future updates.")
                    .fontDesign(.rounded)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.4), radius: 3)

            }
            .padding(.top, -15)
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
                        .shadow(color: .black.opacity(0.4), radius: 3)

                    
                    Text(tip.message)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.4), radius: 3)
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
                        .shadow(color: .black.opacity(0.4), radius: 3)
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
                            .white.opacity(0.6),
                            Color(#colorLiteral(red: 0, green: 0.8159179091, blue: 0.5566406846, alpha: 1)).opacity(0.2),
                            Color(#colorLiteral(red: 0, green: 0.8159179091, blue: 0.5566406846, alpha: 1)).opacity(0.3),
                            .white.opacity(0.1)
                        ], startPoint: .top, endPoint: .bottom),
                        lineWidth: 0.5
                    )
            }
            .shadow(color: .white.opacity(0.4), radius: 5)
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
                    Text("Thank You!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    
                    Text("Every tip helps Teymia Expense grow and stay free.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
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
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 10, opaque: true)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.white.opacity(0.05))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [
                            .white.opacity(0.5),
                            .white.opacity(0.15),
                            .white.opacity(0.15),
                            .white.opacity(0.5)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 0.8
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
