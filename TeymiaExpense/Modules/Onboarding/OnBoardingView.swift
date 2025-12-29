import SwiftUI

// MARK: - OnBoarding Feature Model
struct OnBoardingFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Teymia OnBoarding View
struct TeymiaOnBoardingView: View {
    let onComplete: () -> Void
    
    private let features: [OnBoardingFeature] = [
        OnBoardingFeature(
            icon: "categories",
            title: "onboarding_feature_1_title".localized,
            description: "onboarding_feature_1_description".localized
        ),
        OnBoardingFeature(
            icon: "cards.blank",
            title: "onboarding_feature_2_title".localized,
            description: "onboarding_feature_2_description".localized
        ),
        OnBoardingFeature(
            icon: "bitcoin.symbol",
            title: "onboarding_feature_3_title".localized,
            description: "onboarding_feature_3_description".localized
        )
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon Card
                    VStack(spacing: 16) {
                        Image("app_icon_main")
                            .resizable()
                            .frame(width: 80, height: 80)
                        
                        VStack {
                            Text("welcome_to".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .multilineTextAlignment(.center)
                            Text("Teymia Expense")
                                .font(.title)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.appTint)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 8)
                    
                    // Features Card
                    VStack(spacing: 24) {
                        ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                            FeatureRow(feature: feature)
                                .padding(.horizontal, 30)
                        }
                    }
                }
            }
            .background {
                LivelyFloatingBlobsBackground()
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                VStack(spacing: 12) {
                    // Privacy Notice
                    HStack(spacing: 12) {
                        Image("user.shield")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.appTint)
                        
                        Text("onboarding_privacy_disclaimer".localized)
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: onComplete) {
                        Text("continue".localized)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .tint(Color.appTint)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let feature: OnBoardingFeature
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon
            Image(feature.icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.appTint)
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                
                Text(feature.description)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    TeymiaOnBoardingView {
        print("Onboarding completed")
    }
}
