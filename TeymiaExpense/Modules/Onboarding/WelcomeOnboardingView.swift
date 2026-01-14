import SwiftUI

struct WelcomeOnboardingView: View {
    @Binding var isPresented: Bool
    var onComplete: () -> Void
    
    var body: some View {
        AppleOnBoardingView(tint: .primary, title: "Teymia Expense") {
            Image("app_icon_main")
                .resizable()
                .frame(width: 80, height: 80)
        } cards: {
            AppleOnBoardingCard(
                symbol: "overview.fill",
                title: "onboarding_feature_1_title".localized,
                subTitle: "onboarding_feature_1_description".localized
            )
            AppleOnBoardingCard(
                symbol: "cards.blank",
                title: "onboarding_feature_2_title".localized,
                subTitle: "onboarding_feature_2_description".localized
            )
            AppleOnBoardingCard(
                symbol: "dollar",
                title: "onboarding_feature_3_title".localized,
                subTitle: "onboarding_feature_3_description".localized
            )
        } footer: {
            HStack(spacing: 6) {
                Image("lock")
                    .resizable()
                    .frame(width: 18, height: 18)
                
                Text("onboarding_privacy_disclaimer".localized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 15)
        } onContinue: {
            onComplete()
            isPresented = false
        }
    }
}
