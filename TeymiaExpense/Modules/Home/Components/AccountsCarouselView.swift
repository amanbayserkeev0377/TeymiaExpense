import SwiftUI

struct AccountsCarouselView: View {
    let accounts: [Account]
    @Binding var scrollProgressX: CGFloat
    let topInset: CGFloat
    let scrollOffsetY: CGFloat
    var onAddAccount: () -> Void
    
    private let spacing: CGFloat = 6
    @State private var selectedAccount: Account?
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 0) {
            if accounts.isEmpty {
                AccountEmptyStateView(onAdd: onAddAccount)
            } else {
                // Accounts carousel
                ScrollView(.horizontal) {
                    LazyHStack(spacing: spacing) {
                        ForEach(accounts) { account in
                            AccountCardView(account: account)
                                .onTapGesture {
                                    selectedAccount = account
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, 15, for: .scrollContent)
                .frame(height: 220)
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
                
                // Page indicators
                if accounts.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<accounts.count, id: \.self) { index in
                            Circle()
                                .fill(index == Int(scrollProgressX.rounded()) ? Color.primary : Color.secondary.opacity(0.5))
                                .frame(width: 6, height: 6)
                                .animation(.easeInOut(duration: 0.3), value: scrollProgressX)
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
        .background {
            if !accounts.isEmpty {
                CarouselBackdropView(
                    accounts: accounts,
                    scrollProgressX: scrollProgressX,
                    topInset: topInset,
                    scrollOffsetY: scrollOffsetY
                )
            }
        }
        .sheet(item: $selectedAccount) { account in
            AccountTransactionsView(account: account)
        }
    }
}

// MARK: - Carousel Backdrop View
struct CarouselBackdropView: View {
    let accounts: [Account]
    let scrollProgressX: CGFloat
    let topInset: CGFloat
    let scrollOffsetY: CGFloat
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(accounts.reversed()) { account in
                    let index = CGFloat(accounts.firstIndex(where: { $0.id == account.id }) ?? 0) + 1
                    
                    // Check for custom image first
                    if account.designIndex == -1, let image = account.customUIImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                            .opacity(index - scrollProgressX)
                    } else {
                        switch account.designType {
                        case .image:
                            Image(AccountImageData.image(at: account.designIndex).imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipped()
                                .opacity(index - scrollProgressX)
                            
                        case .color:
                            Rectangle()
                                .fill(AccountColor.gradient(at: account.designIndex))
                                .frame(width: size.width, height: size.height)
                                .opacity(index - scrollProgressX)
                        }
                    }
                }
            }
            .compositingGroup()
            .blur(radius: 8, opaque: true)
            .overlay {
                Rectangle()
                    .fill(.black.opacity(0.15))
            }
            .mask {
                Rectangle()
                    .fill(.linearGradient(colors: [
                        .black,
                        .black.opacity(0.8),
                        .black.opacity(0.7),
                        .black.opacity(0.3),
                        .black.opacity(0.1),
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

// MARK: - Empty View

struct AccountEmptyStateView: View {
    var onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            ZStack {
                AccountCardPreview(
                    name: "account_name".localized,
                    balance: "557231",
                    designType: .color,
                    designIndex: 23,
                    icon: "credit.card",
                    currencyCode: "USD",
                    customImage: nil
                )
                .blur(radius: 4)
                .opacity(0.8)
                
                HStack(spacing: 10) {
                    Text("create_first_account".localized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Image("credit.card")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .glassEffect()
            }
        }
        .buttonStyle(EmptyStateButtonStyle())
        .frame(height: 220)
        .padding(.horizontal, 15)
    }
}

struct EmptyStateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
