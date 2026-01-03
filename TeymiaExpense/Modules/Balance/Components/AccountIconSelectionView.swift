import SwiftUI

struct AccountIconSection: View {
    @Binding var selectedIcon: String
    
    private let availableIcons = [
        "cash", "bank", "credit.card", "piggy.bank",
        "wallet", "expense", "coins", "crypto.coins",
        "nft", "hand.usd", "hand.bill", "star",
        "coins.up", "coins.tax", "shopping.basket", "dollar.sack",
        "dollar.transfer", "scales", "chart.pie", "money.lock",
        "briefcase", "cash.simple", "investment", "bitcoin.symbol", "master.card",
        "bitcoin", "ethereum", "shopify", "paypal",
        "visa", "stripe", "apple.pay", "amazon.pay"
    ]
    
    private var iconColumns: [[String]] {
        stride(from: 0, to: availableIcons.count, by: 3).map {
            Array(availableIcons[$0..<min($0 + 3, availableIcons.count)])
        }
    }
    
    var body: some View {
        Section("icon".localized) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(iconColumns.indices, id: \.self) { columnIndex in
                        VStack(spacing: 16) {
                            ForEach(iconColumns[columnIndex], id: \.self) { icon in
                                iconButton(icon: icon)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
        }
        .listRowInsets(EdgeInsets())
    }
    
    private func iconButton(icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedIcon = icon
            }
        } label: {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(
                    selectedIcon == icon
                    ? Color.primaryInverse
                    : Color.primary
                )
                .padding(10)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? Color.primary.opacity(0.9) : Color.secondary.opacity(0.07))
                )
        }
        .buttonStyle(.plain)
    }
}
