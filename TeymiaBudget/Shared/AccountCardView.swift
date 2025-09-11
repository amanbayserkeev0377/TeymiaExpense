import SwiftUI

// MARK: - Account Card (Банковский стиль)
struct AccountCardView: View {
    let account: Account
    
    private var cardColor: Color {
        account.cardColor
    }
    
    private var cardIcon: String {
        account.cardIcon
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section с иконкой и типом
            HStack {
                // Icon
                Image(cardIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                    )
                
                Spacer()
                
                // Account type badge
                Text(account.type.displayName.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.15))
                    )
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom section с балансом
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text(account.formattedBalance)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    
                    Spacer()
                }
                
                // Currency code в углу
                HStack {
                    Spacer()
                    Text(account.currency.code)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 24)
        }
        .frame(height: 220) // Увеличили высоту
        .frame(maxWidth: .infinity)
        .background(
            // Градиентный фон как у банковских карт
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            cardColor,
                            cardColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Subtle pattern overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                center: .topTrailing,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                )
        )
        .shadow(
            color: cardColor.opacity(0.3),
            radius: 15,
            x: 0,
            y: 8
        )
    }
}

// MARK: - Account Card Preview (для AddAccountView)
struct AccountCardPreview: View {
    let name: String
    let balance: String
    let accountType: AccountType
    let color: Color
    let icon: String
    let currencyCode: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section
            HStack {
                // Icon
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                    )
                
                Spacer()
                
                // Account type badge
                Text(accountType.displayName.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.15))
                    )
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name.isEmpty ? "Account Name" : name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text(balance.isEmpty ? "$0.00" : "$\(balance)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    
                    Spacer()
                }
                
                // Currency code
                HStack {
                    Spacer()
                    Text(currencyCode)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 24)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                center: .topTrailing,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                )
        )
        .shadow(
            color: color.opacity(0.3),
            radius: 15,
            x: 0,
            y: 8
        )
    }
}

// MARK: - Account Carousel (обновленный)
struct AccountCarouselView: View {
    let accounts: [Account]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentIndex) {
                ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                    AccountCardView(account: account)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 240)
            
            if accounts.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<accounts.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? .primary : Color.secondary.opacity(0.2))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}
