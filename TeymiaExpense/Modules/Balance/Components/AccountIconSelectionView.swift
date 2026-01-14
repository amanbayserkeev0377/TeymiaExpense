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
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    
    var body: some View {
        Section {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(availableIcons, id: \.self) { icon in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedIcon = icon
                        }
                    } label: {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.primary)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(.secondary.opacity(0.1))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.secondary.opacity(0.6), lineWidth: 2.5)
                                    .frame(width: 45, height: 45)
                                    .opacity(selectedIcon == icon ? 1 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
