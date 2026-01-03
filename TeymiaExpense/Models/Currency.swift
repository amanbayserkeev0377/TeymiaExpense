import Foundation

struct Currency: Codable, Hashable, Identifiable {
    var id: String { code }
    var code: String
    var symbol: String
    var name: String
    var type: CurrencyType
    
    static let defaultUSD = Currency(code: "USD", symbol: "$", name: "US Dollar", type: .fiat)
}

enum CurrencyType: String, CaseIterable, Codable {
    case fiat = "fiat"
    case crypto = "crypto"
}
