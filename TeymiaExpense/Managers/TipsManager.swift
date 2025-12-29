import StoreKit
import Foundation

// MARK: - Tip Model
struct Tip: Identifiable {
    let id: String
    let image: String
    let name: String
    let message: String
    
    static let allTips: [Tip] = [
        Tip(id: "tip_apple", image: "tip.apple", name: "apple".localized, message: "tip_mini".localized),
        Tip(id: "tip_matcha", image: "tip.matcha", name: "matcha".localized, message: "tip".localized),
        Tip(id: "tip_salad", image: "tip.salad", name: "salad".localized, message: "tip_pro".localized),
        Tip(id: "tip_bowl", image: "tip.bowl", name: "bowl".localized, message: "tip_max".localized)
    ]
}

// MARK: - Store Error
enum StoreError: Error {
    case failedVerification
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
    
    // Transaction listener
    private var transactionListener: Task<Void, Never>?
    
    // Product IDs
    static let tipIDs = ["tip_apple", "tip_matcha", "tip_salad", "tip_bowl"]
    
    // MARK: - Initialization
    
    init() {
        // Start listening for transactions
        transactionListener = listenForTransactions()
        
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached { [weak self] in
            // Iterate through any transactions that don't come from a direct call to `purchase()`
            for await result in StoreKit.Transaction.updates {
                guard let self = self else { return }
                
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Always finish a transaction
                    await transaction.finish()
                    
                    print("✅ Transaction updated: \(transaction.productID)")
                } catch {
                    print("⚠️ Transaction failed verification")
                }
            }
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
            print("✅ Loaded \(products.count) tip products")
        } catch {
            print("⚠️ Failed to load tip products: \(error)")
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
                let transaction = try checkVerified(verification)
                
                // Finish transaction immediately for consumables
                await transaction.finish()
                
                // Show thank you message
                if let tip = Tip.allTips.first(where: { $0.id == product.id }) {
                    await MainActor.run {
                        self.lastPurchasedTip = tip
                        self.showThankYou = true
                    }
                }
                
                print("✅ Tip purchased: \(product.displayName)")
                return true
                
            case .pending:
                print("⏳ Purchase pending")
                return false
                
            case .userCancelled:
                print("❌ User cancelled")
                return false
                
            @unknown default:
                return false
            }
        } catch {
            print("⚠️ Purchase failed: \(error)")
            return false
        }
    }
    
    // MARK: - Verification Helper
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Get Product for Tip
    
    func product(for tip: Tip) -> Product? {
        return tipProducts.first { $0.id == tip.id }
    }
}
