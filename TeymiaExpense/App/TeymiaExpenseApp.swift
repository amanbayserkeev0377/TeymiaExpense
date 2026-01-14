import SwiftUI
import SwiftData

@main
struct TeymiaExpenseApp: App {
    @State private var userPreferences = UserPreferences()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnBoarding = false
    
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
            MainTabView()
                .environment(userPreferences)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnBoarding = true
                    }
                }
                .sheet(isPresented: $showOnBoarding) {
                    WelcomeOnboardingView(isPresented: $showOnBoarding) {
                        setupInitialData()
                    }
                }
        }
    }
    
    @MainActor
    private func setupInitialData() {
        userPreferences.setupInitialData(modelContext: sharedModelContainer.mainContext)
        hasSeenOnboarding = true
    }
}
