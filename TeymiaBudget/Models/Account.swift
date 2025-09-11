import Foundation
import SwiftUI
import SwiftData

extension Account {
    static func createDefault(context: ModelContext) {
        // Get default currency (USD)
        let currencyDescriptor = FetchDescriptor<Currency>()
        let currencies = (try? context.fetch(currencyDescriptor)) ?? []
        
        guard let defaultCurrency = currencies.first(where: { $0.isDefault }) ?? currencies.first else {
            print("Warning: No currencies available to create default account")
            return
        }
        
        let mainAccount = Account(
            name: "Main Account",
            type: .cash,
            balance: 0,
            currency: defaultCurrency,
            isDefault: true,
            customColorHex: AccountColors.color(at: 0).toHex(),
            customIcon: "cash"
        )
        
        context.insert(mainAccount)
    }
}
