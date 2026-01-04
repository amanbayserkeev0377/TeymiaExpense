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
        ])
        
        do {
            let cloudKitConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            let container = try ModelContainer(for: schema, configurations: [cloudKitConfig])
            print("✅ CloudKit ModelContainer created successfully")
            
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
                
                return container
                
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if firstLaunchManager.shouldShowOnboarding {
                    TeymiaOnBoardingView {
                        Category.createDefaults(context: sharedModelContainer.mainContext)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            firstLaunchManager.completeOnboarding()
                        }
                    }
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                } else {
                    MainTabView()
                        .environment(userPreferences)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: firstLaunchManager.shouldShowOnboarding)
        }
        .modelContainer(sharedModelContainer)
    }
}
