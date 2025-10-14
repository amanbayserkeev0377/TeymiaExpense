import SwiftUI

struct AboutSection: View {
    var body: some View {
        Section {
            // Privacy Policy
            Button {
                if let url = URL(string: "https://www.notion.so/Privacy-Policy-28cd5178e65a80e297b2e94f9046ae1d") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Label(
                        title: { Text("Privacy Policy") },
                        icon: {
                            Image("user.shield")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.primary)
                        }
                    )
                    
                    Spacer()
                    
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Terms of Service
            Button {
                if let url = URL(string: "https://www.notion.so/Terms-of-Service-28cd5178e65a804f94cff1e109dbb9d5") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Label(
                        title: { Text("Terms of Service") },
                        icon: {
                            Image("user.document")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.primary)
                        }
                    )
                    
                    Spacer()
                    
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            AttributionsRowView()
        }
        .listRowBackground(Color.mainRowBackground)
    }
}


struct AttributionsRowView: View {
    
    var body: some View {
        ZStack {
            NavigationLink(destination: AttributionsView()) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Label(
                    title: { Text("Attributions") },
                    icon: {
                        Image("link.alt")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.primary)
                    }
                )
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
    }
}

struct AttributionsView: View {
    var body: some View {
        List {
            Section {
                LicenseRow(iconName: "flaticon2", name: "UI icons", attribution: "flaticon.com", url: "https://www.flaticon.com/uicons/interface-icons", iconSize: 32)
                LicenseRow(iconName: "USD", name: "Country Flags", attribution: "flaticon.com", url: "https://www.flaticon.com/packs/countrys-flags?word=flags")
                LicenseRow(iconName: "BTC", name: "Cryptocurrency", attribution: "flaticon.com", url: "https://www.flaticon.com/packs/cryptocurrency-15207963")
            }
        }
        .navigationTitle("Attributions".localized)
        .navigationBarTitleDisplayMode(.inline)
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
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text(attribution)
                    .foregroundStyle(.secondary)
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var cornerRadius: CGFloat {
        switch iconSize {
        case ...30: return 6
        case 31...40: return 8
        case 41...48: return 10
        default: return 12
        }
    }
}
