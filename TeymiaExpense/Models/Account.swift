import Foundation
import SwiftData

@Model
final class Account {
    var name: String = ""
    var balance: Decimal = 0
    var isDefault: Bool = false
    var createdAt: Date = Date()
    
    var designIndex: Int = 0
    var customIcon: String = "cash"
    private var designTypeRawValue: String = "image"
    
    var designType: AccountDesignType {
        get { AccountDesignType(rawValue: designTypeRawValue) ?? .image }
        set { designTypeRawValue = newValue.rawValue }
    }
    
    var currency: Currency? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.toAccount)
    var incomingTransfers: [Transaction]? = []
    
    init(
        name: String,
        balance: Decimal,
        currency: Currency,
        isDefault: Bool = false,
        designIndex: Int = 0,
        customIcon: String = "cash",
        designType: AccountDesignType = .image
    ) {
        self.name = name
        self.balance = balance
        self.currency = currency
        self.isDefault = isDefault
        self.designIndex = designIndex
        self.customIcon = customIcon
        self.designTypeRawValue = designType.rawValue
        self.createdAt = Date()
    }
}

extension Account {
    static func createDefault(context: ModelContext) {
        let currencyDescriptor = FetchDescriptor<Currency>()
        let currencies = (try? context.fetch(currencyDescriptor)) ?? []
        
        guard let defaultCurrency = currencies.first(where: { $0.isDefault }) ?? currencies.first else {
            print("Warning: No currencies available to create default account")
            return
        }
        
        let mainAccount = Account(
            name: "Main Account",
            balance: 0,
            currency: defaultCurrency,
            isDefault: true,
            designIndex: 0,
            customIcon: "cash",
            designType: .image
        )
        
        context.insert(mainAccount)
    }
}

enum AccountDesignType: String, CaseIterable, Codable {
    case image = "image"
    case color = "color"
}
