import Foundation

// MARK: - First Launch Manager
class FirstLaunchManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let firstLaunchKey = "hasSeenOnboarding"
    
    init() {
        self.shouldShowOnboarding = !userDefaults.bool(forKey: firstLaunchKey)
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: firstLaunchKey)
        shouldShowOnboarding = true
    }
}
