import SwiftUI
import SwiftData

@main
struct TeymiaBudgetApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Account.self,
            Budget.self,
            Currency.self
        ])
        
        // Development: in-memory storage (no persistence)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // Данные не сохраняются между запусками
            // cloudKitDatabase: .private("iCloud.com.amanbayserkeev.teymiabudget") // Add later
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
