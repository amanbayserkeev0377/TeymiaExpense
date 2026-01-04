import SwiftUI

struct TeymiaOnBoardingView: View {
    let onComplete: () -> Void
    @State private var hapticTrigger: Bool = false
    
    @State private var data: [DrawOnSymbolEffectExample.SymbolData] = [
        .init(
            name: "chart.bar.xaxis.ascending",
            title: "onboarding_feature_1_title".localized,
            subtitle: "onboarding_feature_1_description".localized,
            preDelay: 0.3
        ),
        .init(
            name: "creditcard.arrow.trianglehead.2.clockwise.rotate.90",
            title: "onboarding_feature_2_title".localized,
            subtitle: "onboarding_feature_2_description".localized,
            preDelay: 1.6
        ),
        .init(
            name: "chineseyuanrenminbisign.circle",
            title: "onboarding_feature_3_title".localized,
            subtitle: "onboarding_feature_3_description".localized,
            preDelay: 1.2
        )
    ]
    
    var body: some View {
        ZStack {
            LivelyFloatingBlobsBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Image("app_icon_main")
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 4) {
                        Text("welcome_to".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Teymia Expense")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color.primary.gradient)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer(minLength: 20)
                
                DrawOnSymbolEffectExample(data: data)
                
                Spacer(minLength: 40)
                
                VStack(spacing: 24) {
                    Button(action: {
                        hapticTrigger.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onComplete()
                        }
                    }) {
                        Text("continue".localized)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .shimmer(.init(
                                tint: .primaryInverse,
                                highlight: .yellow,
                                blur: 5,
                                speed: 1,
                                delay: 2
                            ))
                            .background {
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(Color.primary)
                            }
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 1), trigger: hapticTrigger)
                    .glassEffect(.regular.tint(Color.primary).interactive(), in: Capsule())
                    .shadow(color: Color.primary.opacity(0.1), radius: 10, y: 4)
                    
                    HStack(spacing: 8) {
                        Image("lock")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("onboarding_privacy_disclaimer".localized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 30)
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - DrawOn Component
struct DrawOnSymbolEffectExample: View {
    @State var data: [SymbolData]
    @State private var currentIndex: Int = 0
    @State private var isDisappeared: Bool = false
    var loopDelay: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                ForEach(data) { symbolData in
                    if symbolData.drawOn {
                        Image(systemName: symbolData.name)
                            .font(.system(size: symbolData.symbolSize, weight: .regular))
                            .foregroundStyle(Color.primary.gradient)
                            .transition(.symbolEffect(.drawOn.individually))
                    }
                }
            }
            .frame(width: 120, height: 120)
            
            VStack(spacing: 12) {
                Text(data[currentIndex].title)
                    .font(.title2)
                    .foregroundStyle(Color.primary.gradient)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(data[currentIndex].subtitle)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.secondary.gradient)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .frame(height: 60, alignment: .top)
            }
            .contentTransition(.numericText())
            .animation(.snappy(duration: 1, extraBounce: 0), value: currentIndex)
            .fontDesign(.rounded)
        }
        .task {
            await loopSymbols()
        }
        .onDisappear {
            isDisappeared = true
        }
    }
    
    private func loopSymbols() async {
        for index in data.indices {
            if isDisappeared { return }
            await loopSymbol(index)
        }
        guard !isDisappeared else { return }
        try? await Task.sleep(for: .seconds(loopDelay))
        await loopSymbols()
    }
    
    private func loopSymbol(_ index: Int) async {
        let symbolData = data[index]
        try? await Task.sleep(for: .seconds(symbolData.preDelay))
        if isDisappeared { return }
        data[index].drawOn = true
        currentIndex = index
        try? await Task.sleep(for: .seconds(symbolData.postDelay))
        if isDisappeared { return }
        data[index].drawOn = false
    }
    
    struct SymbolData: Identifiable {
        var id: UUID = UUID()
        var name: String
        var title: String
        var subtitle: String
        var symbolSize: CGFloat = 100
        var preDelay: CGFloat = 1
        var postDelay: CGFloat = 2
        fileprivate var drawOn: Bool = false
    }
}
