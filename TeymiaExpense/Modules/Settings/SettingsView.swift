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
                Button("Reset Onboarding") {
                    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                }
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
                                        .foregroundStyle(.primary)
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
