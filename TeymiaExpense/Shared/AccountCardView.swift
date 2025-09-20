import SwiftUI

// MARK: - Account Card with Images
struct AccountCardView: View {
    let account: Account
    
    var body: some View {
        ZStack {
            // Background based on design type
            switch account.designType {
            case .image:
                Image(AccountImageData.image(at: account.designIndex).imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .containerRelativeFrame(.horizontal)
                    .frame(height: 220)
                    .clipShape(.rect(cornerRadius: 20))
            case .color:
                Rectangle()
                    .fill(AccountColors.gradient(at: account.designIndex))
                    .containerRelativeFrame(.horizontal)
                    .frame(height: 220)
                    .clipShape(.rect(cornerRadius: 20))
            }
            
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
                                .fill(.black.opacity(0.1))
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
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Text(account.formattedBalance)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
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
                            .fontDesign(.rounded)
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
    let designType: AccountDesignType
    let designIndex: Int
    let icon: String
    let currencyCode: String
    
    var body: some View {
        ZStack {
            
            backgroundView
            
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
                                .fill(.black.opacity(0.1))
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
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Text(balance.isEmpty ? "$0.00" : "$\(balance)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
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
                            .fontDesign(.rounded)
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
    
    @ViewBuilder
    private var backgroundView: some View {
        switch designType {
        case .image:
            Image(AccountImageData.image(at: designIndex).imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .containerRelativeFrame(.horizontal)
                .frame(height: 220)
                .clipShape(.rect(cornerRadius: 20))
        case .color:
            Rectangle()
                .fill(AccountColors.gradient(at: designIndex))
                .frame(height: 220)
                .clipShape(.rect(cornerRadius: 20))
        }
    }
}
