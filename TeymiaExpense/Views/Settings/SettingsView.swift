import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label(
                            title: { Text("categories".localized) },
                            icon: {
                                Image("category.management")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.primary)
                            }
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
