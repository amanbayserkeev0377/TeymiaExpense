import SwiftUI

struct CustomSegmentedControl<T: Hashable>: View {
    let options: [T]
    let titles: [String]
    let icons: [String]
    let gradients: [LinearGradient]
    @Binding var selection: T
    
    init(options: [T], titles: [String], icons: [String] = [], gradients: [LinearGradient] = [], selection: Binding<T>) {
        self.options = options
        self.titles = titles
        self.icons = icons
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
                                .frame(width: 20, height: 20)
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
                                .fill(Color.gray.opacity(0.4))
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
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
        self.gradients = []
        self._selection = selection
    }
}
