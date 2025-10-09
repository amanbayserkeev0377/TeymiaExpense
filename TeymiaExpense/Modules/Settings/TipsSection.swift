import SwiftUI

struct TipsSection: View {
    @State private var showingTips = false
    
    var body: some View {
        Section {
            Button {
                showingTips = true
            } label: {
                HStack(spacing: 12) {
                    // Icon
                        Image("gift.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.4470213652, green: 1, blue: 0.6704101562, alpha: 1)),
                                        Color(#colorLiteral(red: 0.1098020747, green: 0.6508788466, blue: 0.6040038466, alpha: 1))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    
                        Text("Buy me a coffee")
                            .font(.body)
                            .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    // Chevron
                    Image("chevron.right")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Color.mainRowBackground)
        .fullScreenSheet(ignoresSafeArea: true, isPresented: $showingTips) { safeArea in
                TipsView()
                .safeAreaPadding(.top, safeArea.top + 35)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.secondary)
                        .frame(width: 45, height: 5)
                        .frame(maxWidth: .infinity)
                        .frame(height: safeArea.top + 30, alignment: .bottom)
                        .offset(y: -10)
                        .contentShape(.rect)
                }
                .clipShape(Background())
        } background: {
            Color.clear
        }
    }
    
    func Background() -> some Shape {
        if #available(iOS 26, *) {
            return ConcentricRectangle(corners: .concentric, isUniform: true)
        } else {
            return RoundedRectangle(cornerRadius: 30)
        }
    }
}

#Preview {
    TipsSection()
}
