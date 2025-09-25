import SwiftUI
import SwiftData

@main
struct TeymiaExpenseApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            CategoryGroup.self,
            Category.self,
            Account.self,
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
    
    Currency.createDefaults(context: context)
    CategoryGroup.createDefaults(context: context)
    Category.createDefaults(context: context)
    Account.createDefault(context: context)
    try? context.save()
}
