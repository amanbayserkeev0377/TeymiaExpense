import SwiftUI

// MARK: - Intro Model
struct Intro: Identifiable {
    let id: UUID = .init()
    var text: String
    var textGradient: GradientStyle
    var circleGradient: GradientStyle
    var bgColor: Color
    var circleOffset: CGFloat = 0
    var textOffset: CGFloat = 0
}

// MARK: - Gradient Style
struct GradientStyle {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(colors: [Color], startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    init(color: Color, startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        self.init(colors: [color, color], startPoint: startPoint, endPoint: endPoint)
    }
    
    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    var shapeStyle: AnyShapeStyle {
        AnyShapeStyle(gradient)
    }
}

// MARK: - OnBoarding View
struct OnBoardingView: View {
    // MARK: - Properties
    let onComplete: () -> Void
    @State private var activeIntro: Intro?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Sample Intros
    private static let intros: [Intro] = [
        Intro(
            text: "Track Expenses",
            textGradient: GradientStyle(colors: [Color(hex: "#747274"), Color(hex: "#2F2C30")]),
            circleGradient: GradientStyle(colors: [Color(hex: "#747274"), Color(hex: "#2F2C30")]),
            bgColor: Color(hex: "#DCFFDB")
        ),
        Intro(
            text: "Multiple Accounts",
            textGradient: GradientStyle(colors: [Color(hex: "#DCFFDB"), Color(hex: "#93AB93")]),
            circleGradient: GradientStyle(colors: [Color(hex: "#DCFFDB"), Color(hex: "#93AB93")]),
            bgColor: Color(hex: "#28044B")
        ),
        Intro(
            text: "200+ Currencies",
            textGradient: GradientStyle(colors: [Color(hex: "#6F5786"), Color(hex: "#28044B")]),
            circleGradient: GradientStyle(colors: [Color(hex: "#6F5786"), Color(hex: "#28044B")]),
            bgColor: Color(hex: "#FF916F")
        ),
        Intro(
            text: "Stay Organized",
            textGradient: GradientStyle(colors: [Color(hex: "#FFB59F"), Color(hex: "#FF916F")]),
            circleGradient: GradientStyle(colors: [Color(hex: "#FFB59F"), Color(hex: "#FF916F")]),
            bgColor: Color(hex: "#2F2C30")
        ),
        Intro(
            text: "Your Privacy First",
            textGradient: GradientStyle(colors: [Color(hex: "#747274"), Color(hex: "#2F2C30")]),
            circleGradient: GradientStyle(colors: [Color(hex: "#747274"), Color(hex: "#2F2C30")]),
            bgColor: Color(hex: "#DCFFDB")
        )
    ]
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if let activeIntro {
                    BackgroundView(intro: activeIntro, size: geometry.size)
                }
                BottomCardView(onComplete: onComplete)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 5)
            }
            .ignoresSafeArea()
        }
        .task {
            if activeIntro == nil {
                activeIntro = Self.intros.first
                try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s delay
                animate(index: 0, loop: true)
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func BackgroundView(intro: Intro, size: CGSize) -> some View {
        Rectangle()
            .fill(intro.bgColor)
            .overlay {
                VStack {
                    Spacer()
                    Circle()
                        .fill(intro.circleGradient.gradient)
                        .frame(width: 38, height: 38)
                        .background(alignment: .leading) {
                            Capsule()
                                .fill(intro.bgColor)
                                .frame(width: size.width)
                        }
                        .background(alignment: .leading) {
                            Text(intro.text)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .foregroundStyle(intro.textGradient.gradient)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .frame(width: min(textSize(intro.text), size.width * 0.75))
                                .offset(x: 10)
                                .offset(x: intro.textOffset)
                        }
                        .offset(x: -intro.circleOffset)
                    Spacer()
                    Spacer()
                }
            }
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func BottomCardView(onComplete: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Image("app_icon_main")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            
            Text("Teymia Expense")
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 8) {
                Image("user.shield")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.white)
                
                Text("Your data stays on your device")
                    .font(.footnote)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white.opacity(0.8))
                    .minimumScaleFactor(0.8)
            }
            .padding(.top, 8)
            
            Button {
                onComplete()
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.appTint)
                    .fillButton(.white.opacity(0.9))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background {
            ZStack {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 10, opaque: true)
                
                LinearGradient(
                    colors: [.black.opacity(0.6), .black.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.1), .white.opacity(0.1), .white.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
        }
        .shadow(color: .white.opacity(0.15), radius: 1, x: 0, y: -1)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -10)
    }
    
    // MARK: - Animation Logic
    private func animate(index: Int, loop: Bool) {
        guard Self.intros.indices.contains(index + 1) else {
            if loop { animate(index: 0, loop: true) }
            return
        }
        
        activeIntro?.text = Self.intros[index].text
        activeIntro?.textGradient = Self.intros[index].textGradient
        
        withAnimation(.snappy(duration: 1), completionCriteria: .removed) {
            activeIntro?.textOffset = -(textSize(Self.intros[index].text) + 20)
            activeIntro?.circleOffset = -(textSize(Self.intros[index].text) + 20) / 2
        } completion: {
            withAnimation(.snappy(duration: 0.8), completionCriteria: .logicallyComplete) {
                activeIntro?.textOffset = 0
                activeIntro?.circleOffset = 0
                activeIntro?.circleGradient = Self.intros[index + 1].circleGradient
                activeIntro?.bgColor = Self.intros[index + 1].bgColor
            } completion: {
                animate(index: index + 1, loop: loop)
            }
        }
    }
    
    // MARK: - Helper
    private func textSize(_ text: String) -> CGFloat {
        NSString(string: text).size(
            withAttributes: [.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
        ).width
    }
}

// MARK: - View Extension
extension View {
    @ViewBuilder
    func fillButton(_ color: Color) -> some View {
        self
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color, in: .rect(cornerRadius: 40))
    }
}

// MARK: - Preview
#Preview {
    OnBoardingView {
    }
}
