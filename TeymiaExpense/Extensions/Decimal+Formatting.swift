import Foundation

extension Decimal {
    
    var isInteger: Bool {
        var rounded = self
        var original = self
        NSDecimalRound(&rounded, &original, 0, .plain)
        
        return rounded == original
    }
    
    func formatted(currency: Currency) -> String {
        return CurrencyFormatter.format(self, currency: currency)
    }
}
