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
            
        }
        .listRowBackground(Color.mainRowBackground)
    }
}
