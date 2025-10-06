import Foundation

struct CurrencyFormatter {
    static func format(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        // Symbol after number
        formatter.currencySymbol = " " + currency.symbol
        formatter.positivePrefix = ""
        formatter.negativePrefix = "-"
        formatter.positiveSuffix = " " + currency.symbol
        formatter.negativeSuffix = " " + currency.symbol
        
        return formatter.string(from: amount as NSDecimalNumber) ?? "0 \(currency.symbol)"
    }
}
