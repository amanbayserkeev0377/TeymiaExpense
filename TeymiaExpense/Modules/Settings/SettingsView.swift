import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(UserPreferences.self) private var userPreferences
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    @Query private var currencies: [Currency]
    @Query private var accounts: [Account]
    @Query private var transactions: [Transaction]
    
    @State private var changeTheme = false
    
    var body: some View {
        NavigationStack {
            List {
                TipsRowView()
                
                Section {
                    Button {
                        changeTheme.toggle()
                    } label: {
                        HStack {
                            Label(
                                title: { Text("Theme") },
                                icon: {
                                    Image(themeIcon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.primary)
                                }
                            )
                            
                            Spacer()
                            
                            Text(userTheme.rawValue)
                                .foregroundStyle(.secondary)
                            
                            Image("chevron.right")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    AppearanceRowView()
                    CurrencySettingsRowView()
                    CloudKitSyncRowView()
                    HiddenTransactionsRowView()
                }
                .listRowBackground(Color.mainRowBackground)
                
                AboutSection()
                
                Section {
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
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 4) {
                                Text("Made with")
                                Image(systemName: "heart.fill")
                                Text("in Kyrgyzstan")
                                Text("🇰🇬")
                            }
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listSectionSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(userTheme.colorScheme)
        .sheet(isPresented: $changeTheme) {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.fraction(0.4)])
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
