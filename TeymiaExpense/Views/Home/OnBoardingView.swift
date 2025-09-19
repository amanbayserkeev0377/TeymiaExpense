import SwiftUI

class FirstLaunchManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool = true // Always show for test

//    @Published var shouldShowOnboarding: Bool
//    
//    private let userDefaults = UserDefaults.standard
//    private let firstLaunchKey = "hasSeenOnboarding"
//    
//    init() {
//        self.shouldShowOnboarding = !userDefaults.bool(forKey: firstLaunchKey)
//    }
    
    func completeOnboarding() {
//        userDefaults.set(true, forKey: firstLaunchKey)
        shouldShowOnboarding = false
    }
}

struct DrawOnSymbolEffectExample: View {
    var tint: Color = .blue
    var buttonTitle: String = "Start Your Journey"
    var loopDelay: CGFloat = 1
    @State var data: [SymbolData]
    var onTap: () -> ()
    @State private var currentIndex: Int = 0
    @State private var isDisappeared: Bool = false
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                ForEach(data) { symbolData in
                    if symbolData.drawOn {
                        Image(systemName: symbolData.name)
                            .font(.system(size: symbolData.symbolSize, weight: .regular))
                            .foregroundStyle(.white)
                            .transition(.symbolEffect(.drawOn.individually))
                    }
                }
            }
            .frame(width: 120, height: 120)
            .background {
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(tint.gradient)
            }
            .geometryGroup()
            .padding(.top, 30)
            
            /// Title & Subtitle With Numeric Content Transition Effect
            VStack(spacing: 6) {
                Text(data[currentIndex].title)
                    .font(.title2)
                    .lineLimit(1)
                
                Text(data[currentIndex].subtitle)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .contentTransition(.numericText())
            .animation(.snappy(duration: 1, extraBounce: 0), value: currentIndex)
            .fontDesign(.rounded)
            .frame(maxWidth: 300)
            .frame(height: 80)
            .geometryGroup()
            
            /// Continue Button
            Button(action: onTap) {
                Text(buttonTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 300)
                    .padding(.vertical, 2)
            }
            .tint(tint.opacity(0.7))
            .buttonStyle(.glassProminent)
        }
        .frame(height: 320)
        .presentationDetents([.height(320)])
        .interactiveDismissDisabled()
        .task {
            await loopSymbols()
        }
        .onDisappear {
            isDisappeared = true
        }
    }
    
    func loopSymbols() async {
        for index in data.indices {
            await loopSymbol(index)
        }
        
        guard !isDisappeared else { return }
        /// Delay to finish the final Draw-off effect
        try? await Task.sleep(for: .seconds(loopDelay))
        await loopSymbols()
    }
    
    func loopSymbol(_ index: Int) async {
        let symbolData = data[index]
        /// Applying Pre-Delay
        try? await Task.sleep(for: .seconds(symbolData.preDelay))
        /// Drawing Symbol
        data[index].drawOn = true
        /// Updating Current Index
        currentIndex = index
        /// Applying Post-Delay
        try? await Task.sleep(for: .seconds(symbolData.postDelay))
        /// Removing Symbol
        data[index].drawOn = false
    }
    
    struct SymbolData: Identifiable {
        var id: UUID = UUID()
        /// Properties
        var name: String
        var title: String
        var subtitle: String
        var symbolSize: CGFloat = 70
        var preDelay: CGFloat = 1
        var postDelay: CGFloat = 2
        var drawOn: Bool = false
    }
}
