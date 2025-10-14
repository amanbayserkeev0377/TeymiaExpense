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
            icon: "category.management",
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
            // Background
            LivelyFloatingBlobsBackground()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // App Icon Card
                        VStack(spacing: 16) {
                            Image("app_icon_main")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            
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
                        VStack(spacing: 0) {
                            ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                                FeatureRow(feature: feature)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                
                                if index < features.count - 1 {
                                    Divider()
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .background {
                            TransparentBlurView(removeAllFilters: true)
                                .blur(radius: 3, opaque: true)
                                .background(Color.mainRowBackground.opacity(0.5))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1),
                                        .white.opacity(0.1),
                                        .white.opacity(0.6)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1.2
                                )
                        }
                        .shadow(color: .black.opacity(0.15), radius: 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
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
                        
                        // Continue Button
                        if #available(iOS 26.0, *) {
                            Button(action: onComplete) {
                                Text("Continue")
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .tint(Color.appTint)
                            .buttonStyle(.glassProminent)
                            .buttonBorderShape(.capsule)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        } else {
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
                    .background {
                        TransparentBlurView(removeAllFilters: true)
                            .blur(radius: 10, opaque: true)
                            .background(Color.clear)
                    }
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
                .frame(width: 26, height: 26)
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
