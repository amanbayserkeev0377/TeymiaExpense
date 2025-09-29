import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Categories
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label(
                            title: { Text("categories".localized) },
                            icon: {
                                Image("category.management")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.primary)
                            }
                        )
                    }
                    // Currency
                    NavigationLink {
                        CurrencySettingsView()
                    } label: {
                        HStack {
                            Image("dollar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
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
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
