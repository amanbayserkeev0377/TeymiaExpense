import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(UserPreferences.self) private var userPreferences
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some View {
        List {
            // MARK: - Support Section
            Section {
                TipsSection()
            }
            
            // MARK: - General Settings
            Section {
                NavigationLink {
                    CategoryManagementView()
                } label: {
                    Label {
                        Text("categories".localized)
                    } icon: {
                        Image("categories")
                            .settingsIcon()
                    }
                }
                
                NavigationLink {
                    CurrencySelectionView(selectedCurrencyCode: userPreferences.baseCurrencyCode) { currency in
                        userPreferences.baseCurrencyCode = currency.code }
                } label: {
                    Label {
                        Text("currency".localized)
                    } icon: {
                        Image("dollar").settingsIcon()
                    }
                }
                
                LanguageSection()
                
                // Theme Picker
                Picker(selection: $themeMode) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                } label: {
                    Label {
                        Text("theme".localized)
                    } icon: {
                        Image(themeMode.iconName).settingsIcon()
                    }
                }
                .pickerStyle(.menu)
                .tint(.secondary)
            }
            
            // MARK: - Legal Section
            Section {
                LegalButton(
                    title: "privacy_policy",
                    icon: "lock",
                    urlString: "https://www.notion.so/Privacy-Policy-28cd5178e65a80e297b2e94f9046ae1d"
                )
                
                LegalButton(
                    title: "terms_of_service",
                    icon: "document",
                    urlString: "https://www.notion.so/Terms-of-Service-28cd5178e65a804f94cff1e109dbb9d5"
                )
            }
            
            // MARK: - Footer
            Section {
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        SocialButton(icon: "soc_github", url: "https://github.com/amanbayserkeev0377/TeymiaExpense")
                        SocialButton(icon: "instagram", url: "https://instagram.com/teymiapps")
                    }
                    AppVersionView()
                }
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .navigationTitle("settings".localized)
    }
}

// MARK: - Support Extension
extension ThemeMode {
    var title: String {
        switch self {
        case .system: return "appearance_system".localized
        case .light: return "appearance_light".localized
        case .dark: return "appearance_dark".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "sun"
        case .light: return "sun"
        case .dark: return "moon"
        }
    }
}

// MARK: - Subviews

struct TipsSection: View {
    @State private var showingTips = false
    
    var body: some View {
        Button {
            showingTips = true
        } label: {
            HStack {
                Label(
                    title: {
                        Text("buy_me_a_matcha".localized)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1)),
                                        Color(#colorLiteral(red: 0.1098020747, green: 0.6508788466, blue: 0.6040038466, alpha: 1))
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    },
                    icon: {
                        Image("gift.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
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
                    }
                )
            }
        }
        .sheet(isPresented: $showingTips) {
            TipsView()
                .presentationDragIndicator(.visible)
        }
    }
}

struct LegalButton: View {
    @Environment(\.openURL) private var openURL
    
    let title: String
    let icon: String
    let urlString: String
    
    var body: some View {
        Button {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            Label {
                Text(title.localized)
            } icon: {
                Image(systemName: icon)
                    .settingsIcon()
            }
        }
        .tint(.primary)
    }
}

struct SocialButton: View {
    let icon: String
    let url: String
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button {
            if let link = URL(string: url) { openURL(link) }
        } label: {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}

struct AppVersionView: View {
    var body: some View {
        VStack(spacing: 4) {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.4"
            Text("Teymia Expense – \("version".localized) \(version)")
                .font(.footnote)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                Text("made_with".localized)
                Image(systemName: "heart.fill")
                Text("in_kyrgyzstan")
                Text("🇰🇬")
            }
            .font(.footnote)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
        }
    }
}

extension Image {
    func settingsIcon() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundStyle(Color.primary)
    }
}
