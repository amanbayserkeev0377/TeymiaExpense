import SwiftUI

struct AccountIconSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedIcon: String
    
    private let availableIcons = [
        "cash", "bank", "credit.card", "piggy.bank",
        "wallet", "expense", "coins", "crypto.coins",
        "nft", "hand.usd", "hand.bill", "hand.revenue",
        "coins.up", "coins.tax", "shopping.basket", "dollar.sack",
        "dollar.transfer", "scales", "chart.pie", "money.lock",
        "briefcase", "cash.simple", "investment", "master.card",
        "bitcoin", "ethereum", "shopify", "paypal",
        "visa", "stripe", "apple.pay", "amazon.pay"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(availableIcons, id: \.self) { icon in
                        iconButton(icon: icon)
                    }
                }
                .padding(20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func iconButton(icon: String) -> some View {
        Button {
            selectedIcon = icon
            dismiss()
        } label: {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(
                    selectedIcon == icon
                    ? (colorScheme == .light ? Color.white : Color.black)
                    : Color.primary
                )
                .padding(14)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? Color.primary.opacity(0.9) : Color(.secondarySystemGroupedBackground))
                )
        }
        .buttonStyle(.plain)
    }
}
