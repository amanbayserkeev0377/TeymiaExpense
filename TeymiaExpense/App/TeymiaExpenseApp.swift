import SwiftUI
import SwiftData

@main
struct TeymiaExpenseApp: App {
    @State private var userPreferences = UserPreferences()
    @StateObject private var firstLaunchManager = FirstLaunchManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Account.self,
            Currency.self
        ])
        
        do {
            let cloudKitConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            let container = try ModelContainer(for: schema, configurations: [cloudKitConfig])
            print("✅ CloudKit ModelContainer created successfully")
            
            createDefaultDataIfNeeded(context: container.mainContext)
            return container
            
        } catch {
            print("⚠️ CloudKit failed, falling back to local storage: \(error)")
            do {
                let localConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
                
                let container = try ModelContainer(for: schema, configurations: [localConfig])
                print("✅ Local ModelContainer created successfully")
                
                createDefaultDataIfNeeded(context: container.mainContext)
                return container
                
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(userPreferences)
                .sheet(isPresented: $firstLaunchManager.shouldShowOnboarding) {
                    TeymiaOnBoardingView() {
                        firstLaunchManager.completeOnboarding()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Default Data Creation
private func createDefaultDataIfNeeded(context: ModelContext) {
    let hasCreatedDefaults = UserDefaults.standard.bool(forKey: "hasCreatedDefaultData_v1_1")
    
    guard !hasCreatedDefaults else {
        print("✅ Default data already exists")
        return
    }
    
    print("📝 Creating default data...")
    
    Currency.createDefaults(context: context)
    Category.createDefaults(context: context)
    Account.createDefault(context: context)

    do {
        try context.save()
        UserDefaults.standard.set(true, forKey: "hasCreatedDefaultData_v1_1")
        print("✅ Default data created successfully")
    } catch {
        print("⚠️ Error saving default data: \(error)")
    }
}
