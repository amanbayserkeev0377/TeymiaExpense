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
            title: "Stay Organized",
            description: "Categorize expenses and see where your money goes"
        ),
        OnBoardingFeature(
            icon: "cards.blank",
            title: "Multiple Accounts",
            description: "Manage all your accounts in one place"
        ),
        OnBoardingFeature(
            icon: "bitcoin.symbol",
            title: "Multi-Currency Support",
            description: "Track expenses in 200+ fiat and crypto currencies"
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
                            Text("Welcome to")
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
                        
                        Text("Your financial data stays on your device and is never shared.")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: onComplete) {
                        Text("Continue")
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
