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
    var customImageData: Data? = nil
    var sortOrder: Int = 0
    
    var designType: AccountDesignType {
        get { AccountDesignType(rawValue: designTypeRawValue) ?? .image }
        set { designTypeRawValue = newValue.rawValue }
    }
    
    private var designTypeRawValue: String = "image"
    
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
        designType: AccountDesignType = .image,
        customImageData: Data? = nil,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.balance = balance
        self.currency = currency
        self.isDefault = isDefault
        self.designIndex = designIndex
        self.customIcon = customIcon
        self.designTypeRawValue = designType.rawValue
        self.customImageData = customImageData
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}

extension Account {
    static func createDefault(context: ModelContext) {
        let descriptor = FetchDescriptor<Account>(
            predicate: #Predicate { $0.isDefault == true }
        )
        let existingDefault = (try? context.fetch(descriptor)) ?? []
        
        if !existingDefault.isEmpty {
            return
        }
        
        // Fallback
        let allDescriptor = FetchDescriptor<Account>()
        let existingAccounts = (try? context.fetch(allDescriptor)) ?? []
        
        if !existingAccounts.isEmpty {
            return
        }
        
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
            designType: .image,
            sortOrder: 0
        )
        
        context.insert(mainAccount)
    }
}

enum AccountDesignType: String, CaseIterable, Codable {
    case image = "image"
    case color = "color"
}
