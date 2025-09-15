import SwiftUI
import SwiftData

@main
struct TeymiaBudgetApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Subcategory.self,
            Account.self,
            Budget.self,
            Currency.self
        ])
        
        // Development: in-memory storage (no persistence)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
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
    let categoryDescriptor = FetchDescriptor<Category>()
    let existingCategories = (try? context.fetch(categoryDescriptor)) ?? []
    
    if !existingCategories.isEmpty {
        print("Categories already exist: \(existingCategories.count)")
        return
    }
    
    print("Creating default data...")
    Currency.createDefaults(context: context)
    print("Created currencies")
    
    Category.createDefaults(context: context)
    print("Created categories")
    
    Subcategory.createDefaults(context: context)
    print("Created subcategories")
    
    Account.createDefault(context: context)
    print("Created accounts")
    
    try? context.save()
    print("Saved all data")
}
