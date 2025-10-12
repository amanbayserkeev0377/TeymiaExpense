import SwiftUI

struct AccountCardView: View {
    let account: Account
    @AppStorage("hideBalance") private var hideBalance: Bool = false
    
    var body: some View {
        ZStack {
            // Background based on design type
            // Check for custom image first (designIndex == -1)
            if account.designIndex == -1, let image = account.customUIImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .containerRelativeFrame(.horizontal)
                    .frame(height: 220)
                    .clipShape(.rect(cornerRadius: 20))
            } else {
                // Standard backgrounds
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
                        .fill(AccountColor.gradient(at: account.designIndex))
                        .containerRelativeFrame(.horizontal)
                        .frame(height: 220)
                        .clipShape(.rect(cornerRadius: 20))
                }
            }
            
            VStack(spacing: 0) {
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
                
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        Text(hideBalance ? "••••" : account.formattedBalance)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.25), value: hideBalance)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            hideBalance.toggle()
                        }
                    } label: {
                        Image(hideBalance ? "eye.crossed" : "eye")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    .offset(y: -10)
                }
                .padding(.bottom, 15)
                .padding(.horizontal, 20)
            }
        }
    }
}
