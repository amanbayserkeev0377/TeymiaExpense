import SwiftUI

struct AttributionsView: View {
    var body: some View {
        BlurNavigationView(
            title: "Attributions",
            showBackButton: true
        ) {
            VStack {
                LicenseRow(
                    iconName: "flaticon2",
                    name: "UI icons",
                    attribution: "flaticon.com",
                    url: "https://www.flaticon.com/uicons/interface-icons",
                )
                
                Divider()
                    .padding(.leading, 44)
                
                LicenseRow(
                    iconName: "USD",
                    name: "Country Flags",
                    attribution: "flaticon.com",
                    url: "https://www.flaticon.com/packs/countrys-flags?word=flags"
                )
                
                Divider()
                    .padding(.leading, 44)
                
                LicenseRow(
                    iconName: "BTC",
                    name: "Cryptocurrency",
                    attribution: "flaticon.com",
                    url: "https://www.flaticon.com/packs/cryptocurrency-15207963"
                )
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.mainRowBackground)
            .cornerRadius(30)
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        .gray.opacity(0.2),
                        lineWidth: 0.7
                    )
            }
            .shadow(color: .black.opacity(0.1), radius: 10)
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.mainBackground)
        .navigationBarHidden(true)
    }
}

struct LicenseRow: View {
    let iconName: String
    let name: String
    let attribution: String
    let url: String
    let iconSize: CGFloat
    
    init(iconName: String, name: String, attribution: String, url: String, iconSize: CGFloat = 26) {
        self.iconName = iconName
        self.name = name
        self.attribution = attribution
        self.url = url
        self.iconSize = iconSize
    }
    
    var body: some View {
        Button {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                
                Text(name)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text(attribution)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .padding(.leading, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
