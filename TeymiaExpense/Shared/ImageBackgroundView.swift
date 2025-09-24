import SwiftUI

struct ImageBackgroundView: View {
    var body: some View {
        Image("customBackground")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: 6)
            .ignoresSafeArea(.all)
    }
}
