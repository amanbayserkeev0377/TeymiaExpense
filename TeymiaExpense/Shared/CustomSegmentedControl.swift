import SwiftUI

struct CustomSegmentedControl<T: Hashable>: View {
    let options: [T]
    let titles: [String]
    let icons: [String]
    let iconSize: CGFloat
    let gradients: [LinearGradient]
    @Binding var selection: T
    
    init(
        options: [T],
        titles: [String],
        icons: [String] = [],
        iconSize: CGFloat = 20,
        gradients: [LinearGradient] = [],
        selection: Binding<T>
    ) {
        self.options = options
        self.titles = titles
        self.icons = icons
        self.iconSize = iconSize
        self.gradients = gradients
        self._selection = selection
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.bouncy(duration: 0.5)) {
                        selection = option
                    }
                } label: {
                    HStack(spacing: 6) {
                        if index < icons.count {
                            Image(icons[index])
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                        }
                        
                        Text(titles[index])
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                    }
                    .foregroundStyle(
                        selection == option && index < gradients.count
                        ? AnyShapeStyle(gradients[index])
                        : AnyShapeStyle(.secondary)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background {
                        if selection == option {
                            Capsule()
                                .fill(Color.mainRowBackground)
                                .overlay {
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.3),
                                                    .white.opacity(0.15),
                                                    .white.opacity(0.15),
                                                    .white.opacity(0.3),
                                                        ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.4
                                        )
                                }
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(Color.gray.opacity(0.1))
        }
    }
    
    // MARK: - Private Properties
    
    @Namespace private var namespace
}

// MARK: - Convenience Initializers

extension CustomSegmentedControl where T == Int {
    init(titles: [String], selection: Binding<Int>) {
        self.options = Array(0..<titles.count)
        self.titles = titles
        self.icons = []
        self.iconSize = 20
        self.gradients = []
        self._selection = selection
    }
}
