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
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Create default data on first launch
            createDefaultDataIfNeeded(context: container.mainContext)
            
            return container
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

// MARK: - Default Data Creation
private func createDefaultDataIfNeeded(context: ModelContext) {
    // Check if we already have data
    let accountDescriptor = FetchDescriptor<Account>()
    let existingAccounts = (try? context.fetch(accountDescriptor)) ?? []
    
    if !existingAccounts.isEmpty {
        return // Data already exists
    }
    
    // Create defaults in order (currencies first, then categories, then accounts)
    Currency.createDefaults(context: context)
    Category.createDefaults(context: context)
    Account.createDefault(context: context)
    
    // Save all default data
    try? context.save()
}
