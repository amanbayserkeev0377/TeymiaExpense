import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(UserPreferences.self) private var userPreferences
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @State private var changeTheme = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            Section {
                TipsSection()
            }
            
            Section {
                NavigationLink {
                    CategoryManagementView()
                } label: {
                    Label {
                        Text("categories".localized)
                    } icon: {
                        Image(systemName: "square.grid.2x2.fill")
                            .settingsIcon(color: .orange)
                    }
                }
            }
            
            
            Section {
                LanguageSection()
                
                NavigationLink {
                    CurrencySettingsView()
                } label: {
                    Label {
                        Text("currency".localized)
                    } icon: {
                        Image(systemName: "coloncurrencysign.circle.fill")
                            .settingsIcon(color: .green)
                    }
                }
                
                NavigationLink {
                    AppearanceSection()
                } label: {
                    Label {
                        Text("appearance".localized)
                    } icon: {
                        Image(systemName: "paintbrush.fill")
                            .settingsIcon(color: .blue)
                    }
                }
                
                NavigationLink {
                    CloudKitSyncView()
                } label: {
                    Label {
                        Text("icloud".localized)
                    } icon: {
                        Image(systemName: "icloud.fill")
                            .settingsIcon(color: .cyan)
                    }
                }
            }
            
            Section {
                Button {
                    if let url = URL(string: "https://www.notion.so/Privacy-Policy-28cd5178e65a80e297b2e94f9046ae1d") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(
                        title: { Text("privacy_policy".localized) },
                        icon: {
                            Image(systemName: "hand.raised.fill")
                                .settingsIcon(color: .blue)
                        }
                    )
                }
                .tint(.primary)
                
                Button {
                    if let url = URL(string: "https://www.notion.so/Terms-of-Service-28cd5178e65a804f94cff1e109dbb9d5") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(
                        title: { Text("terms_of_service".localized) },
                        icon: {
                            Image(systemName: "doc.text.fill")
                                .settingsIcon(color: .gray)
                        }
                    )
                }
                .tint(.primary)
                
                NavigationLink {
                    AttributionsView()
                } label: {
                    Label {
                        Text("attributions".localized)
                    } icon: {
                        Image(systemName: "quote.bubble.fill")
                            .settingsIcon(color: .indigo)
                    }
                }
            }
            
            Section {
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
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        let website = URL(string: "https://instagram.com/teymiapps")!
                        Button {
                            openURL(website, prefersInApp: true)
                        } label: {
                            Image("instagram")
                                .resizable()
                                .frame(width: 24, height: 24)
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
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("settings".localized)
        .navigationBarTitleDisplayMode(.large)
        
    }
}

// MARK: - Tips Section

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
                            .font(.body)
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
                            ) },
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

extension View {
    func settingsIcon(color: Color) -> some View {
        self
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 29, height: 29)
            .background(color.gradient)
            .clipShape(.rect(cornerRadius: 8))
    }
}
