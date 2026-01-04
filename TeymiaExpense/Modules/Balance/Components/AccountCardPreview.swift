import SwiftUI

struct AccountCardPreview: View {
    let name: String
    let balance: String
    let designType: AccountDesignType
    let designIndex: Int
    let icon: String
    let currencyCode: String
    let customImage: UIImage?
    
    var body: some View {
        ZStack {
            backgroundView
            
            // Content
            VStack(spacing: 0) {
                HStack {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.primaryInverse.opacity(0.05))
                        )
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name.isEmpty ? "account_name".localized : name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                        
                        Text(balance.isEmpty ? "0" : "\(balance)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    Image("eye")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                        .offset(y: -10)
                }
                .padding(.bottom, 15)
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        GeometryReader { geometry in
            Group {
                if designIndex == -1, let image = customImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    switch designType {
                    case .image:
                        Image(AccountImageData.image(at: designIndex).imageName)
                            .resizable()
                            .scaledToFill()
                    case .color:
                        Rectangle()
                            .fill(AccountColor.gradient(at: designIndex))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
    }
}
