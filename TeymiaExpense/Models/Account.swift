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
    var designIndex: Int = 0
    var customIcon: String = "cash"
    var customImageData: Data? = nil
    var sortOrder: Int = 0
    
    var designType: AccountDesignType {
        get { AccountDesignType(rawValue: designTypeRawValue) ?? .image }
        set { designTypeRawValue = newValue.rawValue }
    }
    
    private var designTypeRawValue: String = "image"
    
    var currency: Currency {
        CurrencyService.getCurrency(for: currencyCode)
    }
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.toAccount)
    var incomingTransfers: [Transaction]? = []
    
    init(
        name: String,
        balance: Decimal,
        currencyCode: String,
        designIndex: Int = 0,
        customIcon: String = "cash",
        designType: AccountDesignType = .image,
        customImageData: Data? = nil,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.balance = balance
        self.currencyCode = currencyCode
        self.designIndex = designIndex
        self.customIcon = customIcon
        self.designTypeRawValue = designType.rawValue
        self.customImageData = customImageData
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}

enum AccountDesignType: String, CaseIterable, Codable {
    case image = "image"
    case color = "color"
}

extension Account {
    
    var formattedBalance: String {
        return CurrencyFormatter.format(balance, currency: currency)
    }
    
    var cardDarkColor: Color {
        return AccountColor.by(index: designIndex).colors.dark
    }
    
    var cardLightColor: Color {
        return AccountColor.by(index: designIndex).colors.light
    }
    
    var cardGradient: LinearGradient {
        return AccountColor.gradient(at: designIndex)
    }
    
    var cardIcon: String {
        return customIcon
    }
    
    var customUIImage: UIImage? {
        guard let imageData = customImageData else { return nil }
        return UIImage(data: imageData)
    }
}
