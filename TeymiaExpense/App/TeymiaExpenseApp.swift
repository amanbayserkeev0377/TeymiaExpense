import SwiftUI
import SwiftData

@main
struct TeymiaExpenseApp: App {
    @State private var userPreferences = UserPreferences()
    @StateObject private var firstLaunchManager = FirstLaunchManager()
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            CategoryGroup.self,
            Category.self,
            Account.self,
            Currency.self
        ])
        
        // Try CloudKit first with detailed error logging
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
            
        } catch let error as NSError {
            print("❌ CloudKit Error Details:")
            print("   Domain: \(error.domain)")
            print("   Code: \(error.code)")
            print("   Description: \(error.localizedDescription)")
            print("   User Info: \(error.userInfo)")
            
            // Try local storage as fallback
            print("⚠️ Trying local storage fallback...")
            
            do {
                let localConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
                
                let container = try ModelContainer(for: schema, configurations: [localConfig])
                print("✅ Local ModelContainer created successfully")
                
                createDefaultDataIfNeeded(context: container.mainContext)
                return container
                
            } catch let localError as NSError {
                print("❌ Local Storage Error Details:")
                print("   Domain: \(localError.domain)")
                print("   Code: \(localError.code)")
                print("   Description: \(localError.localizedDescription)")
                print("   User Info: \(localError.userInfo)")
                
                fatalError("Could not create ModelContainer even with local storage: \(localError)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(userPreferences)
                .preferredColorScheme(userTheme.colorScheme)
                .sheet(isPresented: $firstLaunchManager.shouldShowOnboarding) {
                    TeymiaOnBoardingView {
                        firstLaunchManager.completeOnboarding()
                    }
                }
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
