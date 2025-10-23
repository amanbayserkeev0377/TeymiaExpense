import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(UserPreferences.self) private var userPreferences
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    @Query private var currencies: [Currency]
    @Query private var accounts: [Account]
    @Query private var transactions: [Transaction]
    
    @Query(filter: #Predicate<Transaction> { $0.isHidden == true })
    private var hiddenTransactions: [Transaction]
    
    @State private var changeTheme = false
    
    var body: some View {
        NavigationStack {
            BlurNavigationView(
                title: "Settings",
                showBackButton: false
            ) {
                VStack(spacing: 24) {
                    // Tips Section
                    TipsSection()
                    
                    // General Section
                    SettingsSection(title: "General") {
                        // Theme
                        SettingsRow(
                            icon: themeIcon,
                            title: "Theme",
                            subtitle: userTheme.rawValue
                        ) {
                            changeTheme.toggle()
                        }
                        
                        SettingsDivider()
                        
                        // Appearance
                        SettingsLinkRow(
                            icon: "paintbrush",
                            title: "Appearance"
                        ) {
                            AppearanceView()
                        }
                        
                        SettingsDivider()
                        
                        // Currency
                        SettingsLinkRow(
                            icon: "usd.circle",
                            title: "Currency",
                            subtitle: userPreferences.baseCurrencyCode
                        ) {
                            CurrencySettingsView()
                        }
                        
                        SettingsDivider()
                        
                        // iCloud Sync
                        SettingsLinkRow(
                            icon: "cloud.upload",
                            title: "iCloud Sync"
                        ) {
                            CloudKitSyncView()
                        }
                        
                        SettingsDivider()
                        
                        // Hidden Transactions
                        SettingsLinkRow(
                            icon: "eye.crossed",
                            title: "Hidden Transactions",
                            subtitle: hiddenTransactions.count > 0 ? "\(hiddenTransactions.count)" : nil
                        ) {
                            HiddenTransactionsView()
                        }
                    }
                    
                    // About Section
                    SettingsSection(title: "About") {
                        // Privacy Policy
                        SettingsRow(
                            icon: "user.shield",
                            title: "Privacy Policy"
                        ) {
                            if let url = URL(string: "https://www.notion.so/Privacy-Policy-28cd5178e65a80e297b2e94f9046ae1d") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsDivider()
                        
                        // Terms of Service
                        SettingsRow(
                            icon: "user.document",
                            title: "Terms of Service"
                        ) {
                            if let url = URL(string: "https://www.notion.so/Terms-of-Service-28cd5178e65a804f94cff1e109dbb9d5") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsDivider()
                        
                        // Attributions
                        SettingsLinkRow(
                            icon: "link.alt",
                            title: "Attributions"
                        ) {
                            AttributionsView()
                        }
                    }
                    
                    // Social & Version Section
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            Button {
                                if let url = URL(string: "https://github.com/amanbayserkeev0377/TeymiaExpense") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Image("soc_github")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.secondary)
                            }
                            .buttonStyle(.plain)

                            Button {
                                if let url = URL(string: "https://t.me/amanbayserkeev0377") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Image("soc_telegram")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.secondary)

                            }
                            .buttonStyle(.plain)
                        }
                        
                        VStack(spacing: 4) {
                            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.4"
                            
                            Text("Teymia Expense – \("version".localized) \(version)")
                                .font(.footnote)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 4) {
                                Text("Made with")
                                Image(systemName: "heart.fill")
                                Text("in Kyrgyzstan")
                                Text("🇰🇬")
                            }
                            .font(.footnote)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
                .padding(.vertical, 20)
            }
            .background(Color.mainBackground)
            .navigationBarHidden(true)
        }
        .preferredColorScheme(userTheme.colorScheme)
        .sheet(isPresented: $changeTheme) {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.fraction(0.4)])
                .presentationCornerRadius(40)
        }
    }
    
    // MARK: - Computed Properties
    
    private var themeIcon: String {
        switch userTheme {
        case .systemDefault:
            return "circle.half"
        case .light:
            return "sun"
        case .dark:
            return "moon"
        }
    }
}

// MARK: - Tips Section

struct TipsSection: View {
    @State private var showingTips = false
    
    var body: some View {
        Button {
            showingTips = true
        } label: {
            HStack(spacing: 12) {
                Image("gift.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(#colorLiteral(red: 0.4470213652, green: 1, blue: 0.6704101562, alpha: 1)),
                                Color(#colorLiteral(red: 0.1098020747, green: 0.6508788466, blue: 0.6040038466, alpha: 1))
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Buy me a matcha")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1)),
                                Color(#colorLiteral(red: 0.1098020747, green: 0.6508788466, blue: 0.6040038466, alpha: 1))
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.mainRowBackground)
        .cornerRadius(30)
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.3),
                            .white.opacity(0.15),
                            .white.opacity(0.15),
                            .white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.4
                )
        }
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.horizontal, 16)
        .fullScreenSheet(ignoresSafeArea: true, isPresented: $showingTips) { safeArea in
            TipsView()
                .safeAreaPadding(.top, safeArea.top + 35)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.secondary)
                        .frame(width: 45, height: 5)
                        .frame(maxWidth: .infinity)
                        .frame(height: safeArea.top + 30, alignment: .bottom)
                        .offset(y: -10)
                        .contentShape(.rect)
                }
                .clipShape(Background())
        } background: {
            Color.clear
        }
    }
    
    func Background() -> some Shape {
        if #available(iOS 26, *) {
            return ConcentricRectangle(corners: .concentric, isUniform: true)
        } else {
            return RoundedRectangle(cornerRadius: 30)
        }
    }
}
