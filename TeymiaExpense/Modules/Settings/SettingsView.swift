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
                Section {
                    Button {
                        changeTheme.toggle()
                    } label: {
                        HStack {
                            Image(themeIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.primary)
                            
                            Text("Appearance")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(userTheme.rawValue)
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.mainRowBackground)
                
                // Data Management Section
                Section {
                    NavigationLink {
                        AccountsManagementView()
                    } label: {
                        HStack {
                            Image("cards.blank")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.primary)
                            
                            Text("Accounts")
                            
                            Spacer()
                            
                            Text("\(accounts.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        HStack {
                            Image("category.management")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.primary)
                            
                            Text("categories".localized)
                        }
                    }
                    
                    NavigationLink {
                        CurrencySettingsView()
                    } label: {
                        HStack {
                            Image("dollar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.primary)
                            
                            Text("currency".localized)
                            
                            Spacer()
                            
                            Text(userPreferences.baseCurrencyCode)
                                .foregroundStyle(.secondary)
                        }
                    }
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
