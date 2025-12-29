import Foundation

struct CurrencyFormatter {
    static func format(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = " " + currency.symbol
        formatter.positivePrefix = ""
        formatter.negativePrefix = "-"
        formatter.positiveSuffix = " " + currency.symbol
        formatter.negativeSuffix = " " + currency.symbol
        formatter.minimumFractionDigits = 0
        
        if amount.isInteger {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: amount as NSDecimalNumber) ?? "0 \(currency.symbol)"
    }
}
