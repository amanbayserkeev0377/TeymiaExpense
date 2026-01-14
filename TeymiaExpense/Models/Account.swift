import Foundation
import SwiftData
import SwiftUI

@Model
final class Account {
    var id: UUID = UUID()
    var name: String = ""
    var balance: Decimal = 0
    var currencyCode: String = "USD"
    var createdAt: Date = Date()
    var customIcon: String = "cash"
    var sortOrder: Int = 0
    var hexColor: String?
    
    private var iconColorRawValue: String = "gray"
    
    var iconColor: IconColor {
        get { IconColor(rawValue: iconColorRawValue) ?? .color1}
        set { iconColorRawValue = newValue.rawValue }
    }
    
    @Transient
    var actualColor: Color {
        if let hex = hexColor {
            return Color(hex: hex)
        }
        return iconColor.color
    }
    
    var currency: Currency {
        CurrencyService.getCurrency(for: currencyCode)
    }
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.toAccount)
    var incomingTransfers: [Transaction]? = []
    
    init(
        id: UUID = UUID(),
        name: String,
        balance: Decimal,
        currencyCode: String,
        customIcon: String = "cash",
        iconColor: IconColor = .color1,
        hexColor: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currencyCode = currencyCode
        self.customIcon = customIcon
        self.iconColorRawValue = iconColor.rawValue
        self.hexColor = hexColor
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}

extension Account {
    @MainActor
    static func createDefaults(context: ModelContext, userCurrency: String) {
        let descriptor = FetchDescriptor<Account>()
        let existingAccounts = (try? context.fetch(descriptor)) ?? []
        
        // Deterministic ID for the primary account
        guard let mainAccountUUID = UUID(uuidString: "DEFA11ED-ACCC-4000-8000-000000000001") else { return }
        
        // Prevent dublicate creation
        if !existingAccounts.contains(where: { $0.id == mainAccountUUID }) {
            let mainAccount = Account(
                id: mainAccountUUID,
                name: "cash".localized,
                balance: 0,
                currencyCode: userCurrency,
                customIcon: "cash",
                iconColor: .color1,
                sortOrder: 0
            )
            context.insert(mainAccount)
            try? context.save()
        }
    }
    
    var formattedBalance: String {
        return CurrencyFormatter.format(balance, currency: currency)
    }
    
    var cardIcon: String {
        return customIcon
    }
}
