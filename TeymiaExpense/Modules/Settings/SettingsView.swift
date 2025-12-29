import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(UserPreferences.self) private var userPreferences
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @State private var changeTheme = false
    
    var body: some View {
        List {
            Section {
                TipsSection()
            }
            .listRowBackground(Color.mainRowBackground)
            
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
            }
            .listRowBackground(Color.mainRowBackground)

            
            Section {
                LanguageSection()
                
                NavigationLink {
                    CurrencySettingsView()
                } label: {
                    Label {
                        Text("currency".localized)
                    } icon: {
                        Image("usd.circle")
                            .settingsIcon()
                    }
                }
                
                NavigationLink {
                    AppearanceSection()
                } label: {
                    Label {
                        Text("appearance".localized)
                    } icon: {
                        Image("paintbrush")
                            .settingsIcon()
                    }
                }
                
                NavigationLink {
                    CloudKitSyncView()
                } label: {
                    Label {
                        Text("icloud".localized)
                    } icon: {
                        Image("cloud.upload")
                            .settingsIcon()
                    }
                }
                
                NavigationLink {
                    HiddenTransactionsView()
                } label: {
                    Label {
                        Text("hidden_transactions".localized)
                    } icon: {
                        Image("eye.crossed")
                            .settingsIcon()
                    }
                }
            }
            .listRowBackground(Color.mainRowBackground)
            
            Section {
                Button {
                    if let url = URL(string: "https://www.notion.so/Privacy-Policy-28cd5178e65a80e297b2e94f9046ae1d") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(
                        title: { Text("privacy_policy".localized) },
                        icon: {
                            Image("user.shield")
                                .settingsIcon()
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
                            Image("user.document")
                                .settingsIcon()
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
                        Image("link.alt")
                            .settingsIcon()
                    }
                }
            }
            .listRowBackground(Color.mainRowBackground)
            
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
                        
                        Button {
                            if let url = URL(string: "https://instagram.com/teymiapps") {
                                UIApplication.shared.open(url)
                            }
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
        .scrollContentBackground(.hidden)
        .background(Color.mainGroupBackground)
        .navigationTitle("settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        
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
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }
}

extension Image {
    func settingsIcon() -> some View {
        self
            .resizable()
            .frame(width: 18, height: 18)
            .foregroundStyle(Color.primary)
    }
}
