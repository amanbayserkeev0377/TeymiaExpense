import SwiftUI
import SwiftData

@main
struct TeymiaExpenseApp: App {
    @State private var userPreferences = UserPreferences()
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            CategoryGroup.self,
            Category.self,
            Account.self,
            Currency.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Create default data synchronously if needed
            createDefaultDataIfNeeded(context: container.mainContext)
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(userPreferences)
                .preferredColorScheme(userTheme.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Synchronous Default Data Creation
private func createDefaultDataIfNeeded(context: ModelContext) {
    let categoryDescriptor = FetchDescriptor<Category>()
    let existingCategories = (try? context.fetch(categoryDescriptor)) ?? []
    
    if !existingCategories.isEmpty {
        return
    }
    
    Currency.createDefaults(context: context)
    CategoryGroup.createDefaults(context: context)
    Category.createDefaults(context: context)
    Account.createDefault(context: context)
    try? context.save()
}
