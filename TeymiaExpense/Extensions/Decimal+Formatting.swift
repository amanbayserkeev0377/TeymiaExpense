import Foundation

extension Decimal {
    func formatted(currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: self as NSDecimalNumber) ?? "\(currency.symbol)0"
    }
}
