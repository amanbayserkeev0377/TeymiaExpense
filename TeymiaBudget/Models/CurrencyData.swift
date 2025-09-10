import Foundation
import SwiftData

// MARK: - Currency Data
struct CurrencyData {
    
    // MARK: - Top Fiat Currencies with symbols (by trading volume)
    static let topFiatCurrencies: [(code: String, symbol: String, name: String)] = [
        ("USD", "$", "US Dollar"),
        ("EUR", "€", "Euro"),
        ("JPY", "¥", "Japanese Yen"),
        ("GBP", "£", "British Pound"),
        ("CNY", "¥", "Chinese Yuan"),
        ("AUD", "A$", "Australian Dollar"),
        ("CAD", "C$", "Canadian Dollar"),
        ("CHF", "CHF", "Swiss Franc"),
        ("HKD", "HK$", "Hong Kong Dollar"),
        ("SGD", "S$", "Singapore Dollar"),
        ("SEK", "kr", "Swedish Krona"),
        ("NOK", "kr", "Norwegian Krone"),
        ("DKK", "kr", "Danish Krone"),
        ("KRW", "₩", "South Korean Won"),
        ("INR", "₹", "Indian Rupee"),
        ("BRL", "R$", "Brazilian Real"),
        ("MXN", "$", "Mexican Peso"),
        ("ZAR", "R", "South African Rand"),
        ("RUB", "₽", "Russian Ruble"),
        ("KGS", "сом", "Kyrgyzstani Som"),
        // Additional popular currencies
        ("NZD", "NZ$", "New Zealand Dollar"),
        ("PLN", "zł", "Polish Zloty"),
        ("CZK", "Kč", "Czech Koruna"),
        ("HUF", "Ft", "Hungarian Forint"),
        ("ILS", "₪", "Israeli Shekel"),
        ("TRY", "₺", "Turkish Lira"),
        ("AED", "AED", "UAE Dirham"),
        ("SAR", "SR", "Saudi Riyal"),
        ("THB", "฿", "Thai Baht"),
        ("MYR", "RM", "Malaysian Ringgit")
    ]
    
    // MARK: - Top Crypto Currencies with symbols (by market cap)
    static let topCryptoCurrencies: [(code: String, symbol: String, name: String)] = [
        ("BTC", "₿", "Bitcoin"),
        ("ETH", "Ξ", "Ethereum"),
        ("USDT", "₮", "Tether"),
        ("XRP", "XRP", "XRP"),
        ("BNB", "BNB", "BNB"),
        ("SOL", "SOL", "Solana"),
        ("USDC", "USDC", "USD Coin"),
        ("DOGE", "Ð", "Dogecoin"),
        ("ADA", "₳", "Cardano"),
        ("TRX", "TRX", "TRON"),
        ("AVAX", "AVAX", "Avalanche"),
        ("TON", "TON", "Toncoin"),
        ("LINK", "LINK", "Chainlink"),
        ("DOT", "DOT", "Polkadot"),
        ("LTC", "Ł", "Litecoin"),
        ("UNI", "UNI", "Uniswap"),
        ("ATOM", "ATOM", "Cosmos"),
        ("XLM", "XLM", "Stellar"),
        ("XMR", "XMR", "Monero"),
        ("SHIB", "SHIB", "Shiba Inu")
    ]
    
    // MARK: - Create Currency Objects
    static func createDefaultCurrencies() -> [Currency] {
        var currencies: [Currency] = []
        
        // Add fiat currencies
        for (index, currencyData) in topFiatCurrencies.enumerated() {
            let currency = Currency(
                code: currencyData.code,
                symbol: currencyData.symbol,
                name: currencyData.name,
                type: .fiat,
                isDefault: index == 0 // USD is default
            )
            currencies.append(currency)
        }
        
        // Add crypto currencies
        for currencyData in topCryptoCurrencies {
            let currency = Currency(
                code: currencyData.code,
                symbol: currencyData.symbol,
                name: currencyData.name,
                type: .crypto,
                isDefault: false
            )
            currencies.append(currency)
        }
        
        return currencies
    }
    
    // MARK: - Helper Methods
    static func getAllCurrencies() -> [Currency] {
        return createDefaultCurrencies()
    }
    
    static func getCurrencies(for type: CurrencyType) -> [Currency] {
        return getAllCurrencies().filter { $0.type == type }
    }
    
    static func findCurrency(by code: String) -> Currency? {
        return getAllCurrencies().first { $0.code == code }
    }
    
    static func searchCurrencies(query: String, type: CurrencyType? = nil) -> [Currency] {
        let currencies = type == nil ? getAllCurrencies() : getCurrencies(for: type!)
        
        if query.isEmpty {
            return currencies
        }
        
        return currencies.filter { currency in
            currency.code.lowercased().contains(query.lowercased()) ||
            currency.name.lowercased().contains(query.lowercased())
        }.sorted { lhs, rhs in
            // Exact code match first
            let lhsExactMatch = lhs.code.lowercased() == query.lowercased()
            let rhsExactMatch = rhs.code.lowercased() == query.lowercased()
            
            if lhsExactMatch && !rhsExactMatch { return true }
            if !lhsExactMatch && rhsExactMatch { return false }
            
            return lhs.code < rhs.code
        }
    }
}

// MARK: - Currency Extensions
extension Currency {
    static func createDefaults(context: ModelContext) {
        let currencies = CurrencyData.createDefaultCurrencies()
        
        for currency in currencies {
            context.insert(currency)
        }
    }
}
class CurrencyService {
    static let shared = CurrencyService()
    private init() {}
    
    // Get icon name for currency (flag for fiat, crypto icon for crypto)
    func getCurrencyIcon(for currency: Currency) -> String {
        switch currency.type {
        case .fiat:
            return getFlagIcon(for: currency.code)
        case .crypto:
            return getCryptoIcon(for: currency.code)
        }
    }
    
    private func getFlagIcon(for currencyCode: String) -> String {
        // Icons in Assets are named by currency codes directly (USD, EUR, CNY, etc.)
        return currencyCode.uppercased()
    }
    
    private func getCryptoIcon(for currencyCode: String) -> String {
        // Crypto icons are also named by currency codes (BTC, ETH, etc.)
        return currencyCode.uppercased()
    }
}
