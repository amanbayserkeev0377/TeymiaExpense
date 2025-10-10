import Foundation
import SwiftData

@Model
final class Currency {
    var code: String = ""
    var symbol: String = ""
    var name: String = ""
    private var typeRawValue: String = "fiat"
    var isDefault: Bool = false
    var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify, inverse: \Account.currency)
    var accounts: [Account]? = []
    var type: CurrencyType {
        get { CurrencyType(rawValue: typeRawValue) ?? .fiat }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(
        code: String,
        symbol: String,
        name: String,
        type: CurrencyType,
        isDefault: Bool = false
    ) {
        self.code = code
        self.symbol = symbol
        self.name = name
        self.typeRawValue = type.rawValue
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

enum CurrencyType: String, CaseIterable, Codable {
    case fiat = "fiat"
    case crypto = "crypto"
}

extension Currency {
    static func createDefaults(context: ModelContext) {
        let currencies = CurrencyService.createDefaultCurrencies()
        
        for currency in currencies {
            context.insert(currency)
        }
    }
}
