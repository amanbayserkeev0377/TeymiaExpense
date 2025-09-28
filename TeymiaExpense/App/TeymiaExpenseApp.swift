import SwiftUI
import SwiftData

@main
struct TeymiaExpenseApp: App {
    @State private var userPreferences = UserPreferences()
    @State private var isDataLoaded = false
    
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
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isDataLoaded {
                MainTabView()
                    .environment(userPreferences)
            } else {
                // Loading placeholder
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.headline)
                        .padding(.top)
                }
                .task {
                    await createDefaultDataIfNeeded()
                    isDataLoaded = true
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Async Default Data Creation
    private func createDefaultDataIfNeeded() async {
        let context = sharedModelContainer.mainContext
        
        await MainActor.run {
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
    }
}
