import SwiftUI

// MARK: - Account Card with Images
struct AccountCardView: View {
    let account: Account
    
    var body: some View {
        ZStack {
            // Background Image
            Image(account.cardImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .containerRelativeFrame(.horizontal)
                .frame(height: 380)
                .clipShape(.rect(cornerRadius: 10))
                .shadow(color: .black.opacity(0.4), radius: 5, x: 5, y: 5)
            
            // Content
            VStack(spacing: 0) {
                // Top section with icon
                HStack {
                    Image(account.cardIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.black.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom section with balance
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Text(account.formattedBalance)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        }
                        
                        Spacer()
                    }
                    
                    // Currency code
                    HStack {
                        Spacer()
                        Text(account.currency.code)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Account Card Preview for AddAccountView
struct AccountCardPreview: View {
    let name: String
    let balance: String
    let imageIndex: Int
    let icon: String
    let currencyCode: String
    
    var body: some View {
        ZStack {
            // Background Image
            Image(AccountImageData.image(at: imageIndex).imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 240)
                .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    .black.opacity(0.1),
                    .black.opacity(0.3),
                    .black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(spacing: 0) {
                // Top section
                HStack {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.black.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
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
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Text(balance.isEmpty ? "$0.00" : "$\(balance)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        }
                        
                        Spacer()
                    }
                    
                    // Currency code
                    HStack {
                        Spacer()
                        Text(currencyCode)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
