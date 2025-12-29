import SwiftUI

struct AttributionsView: View {
    var body: some View {
        List {
                LicenseRow(
                    iconName: "flaticon2",
                    name: "UI icons",
                    attribution: "flaticon.com",
                    url: "https://www.flaticon.com/uicons/interface-icons",
                )
                LicenseRow(
                    iconName: "USD",
                    name: "Country Flags",
                    attribution: "flaticon.com",
                    url: "https://www.flaticon.com/packs/countrys-flags?word=flags"
                )
                LicenseRow(
                    iconName: "BTC",
                    name: "Cryptocurrency",
                    attribution: "flaticon.com",
                    url: "https://www.flaticon.com/packs/cryptocurrency-15207963"
                )
        }
    }
}

struct LicenseRow: View {
    let iconName: String
    let name: String
    let attribution: String
    let url: String
    let iconSize: CGFloat
    
    init(iconName: String, name: String, attribution: String, url: String, iconSize: CGFloat = 20) {
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
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
