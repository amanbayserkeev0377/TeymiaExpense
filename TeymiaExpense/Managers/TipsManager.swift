import StoreKit
import Foundation

// MARK: - Tip Model
struct Tip: Identifiable {
    let id: String
    let image: String
    let name: String
    let message: String
    
    static let allTips: [Tip] = [
        Tip(id: "tip_cookie", image: "tip.cookie", name: "Cookie", message: "Tip mini"),
        Tip(id: "tip_coffee", image: "tip.coffee", name: "Coffee", message: "Tip"),
        Tip(id: "tip_burger", image: "tip.burger", name: "Burger", message: "Tip Pro"),
        Tip(id: "tip_pizza", image: "tip.pizza", name: "Pizza", message: "Tip Pro Max")
    ]
}

// MARK: - Tips Manager
@Observable
class TipsManager {
    // Products
    var tipProducts: [Product] = []
    
    // Loading states
    var isLoading = false
    var isPurchasing = false
    
    // Success state
    var lastPurchasedTip: Tip?
    var showThankYou = false
    
    // Product IDs
    static let tipIDs = ["tip_cookie", "tip_coffee", "tip_burger", "tip_pizza"]
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadProducts()
        }
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let products = try await Product.products(for: Self.tipIDs)
            await MainActor.run {
                // Sort by price: cheapest first
                self.tipProducts = products.sorted { $0.price < $1.price }
            }
        } catch {
            print("Failed to load tip products: \(error)")
        }
    }
    
    // MARK: - Purchase Tip
    
    func purchaseTip(_ product: Product) async -> Bool {
        guard !isPurchasing else { return false }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Finish transaction immediately for consumables
                    await transaction.finish()
                    
                    // Show thank you message
                    if let tip = Tip.allTips.first(where: { $0.id == product.id }) {
                        await MainActor.run {
                            self.lastPurchasedTip = tip
                            self.showThankYou = true
                        }
                    }
                    
                    print("Tip purchased: \(product.displayName)")
                    return true
                    
                case .unverified:
                    print("Transaction failed verification")
                    return false
                }
                
            case .pending:
                print("Purchase pending")
                return false
                
            case .userCancelled:
                print("User cancelled")
                return false
                
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }
    
    // MARK: - Get Product for Tip
    
    func product(for tip: Tip) -> Product? {
        return tipProducts.first { $0.id == tip.id }
    }
}
