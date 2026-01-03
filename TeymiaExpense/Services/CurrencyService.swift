import Foundation
import SwiftData

struct CurrencyService {
    
    static func detectUserCurrency() -> String {
        // Get user's locale
        let userLocale = Locale.current
        
        // Try to get currency from locale
        if let currencyCode = userLocale.currency?.identifier {
            return currencyCode
        }
        
        // Fallback: map region to currency
        if let regionCode = userLocale.region?.identifier {
            let currencyByRegion = getCurrencyForRegion(regionCode)
            return currencyByRegion
        }
        
        // Ultimate fallback - USD
        return "USD"
    }
    
    private static func getCurrencyForRegion(_ regionCode: String) -> String {
        let regionToCurrency: [String: String] = [
            // Major regions
            "US": "USD", "CA": "CAD", "GB": "GBP",
            "AU": "AUD", "JP": "JPY", "CN": "CNY", "IN": "INR",
            "BR": "BRL", "MX": "MXN", "KR": "KRW", "SG": "SGD",
            "CH": "CHF", "SE": "SEK", "NO": "NOK", "DK": "DKK",
            "PL": "PLN", "CZ": "CZK", "HU": "HUF", "IL": "ILS",
            "TR": "TRY", "AE": "AED", "SA": "SAR", "TH": "THB",
            "MY": "MYR", "ZA": "ZAR", "RU": "RUB",
            
            // CIS countries
            "KG": "KGS", "KZ": "KZT", "UZ": "UZS", "TJ": "TJS",
            "AM": "AMD", "AZ": "AZN", "GE": "GEL", "MD": "MDL",
            "UA": "UAH", "BY": "BYN"
        ]
        
        return regionToCurrency[regionCode] ?? "USD"
    }
    
    static func getSymbol(for code: String?) -> String {
            guard let code = code else {
                return "$"
            }
            return getCurrency(for: code).symbol
        }

        static func getSymbol(for currency: Currency) -> String {
            return currency.symbol
        }
    
    static func getCurrency(for code: String) -> Currency {
            return CurrencyDataProvider.findCurrency(by: code) ?? .defaultUSD
        }
    
    static func getCurrencyIcon(for currency: Currency) -> String {
        return currency.code.uppercased()
    }
}
