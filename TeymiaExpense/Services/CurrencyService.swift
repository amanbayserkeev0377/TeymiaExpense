import Foundation
import SwiftData
import SwiftUI

class CurrencyService {
    
    static let shared = CurrencyService()
    
    // MARK: - Dependencies
    private let apiService = APIService.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private let lastRatesKey = "lastRates"
    private let lastUpdateKey = "lastUpdate"
    
    private init() {}
    
    // MARK: - Exchange Rates Logic
    
    func refreshRates(for accounts: [Account], baseCurrencyCode: String) async {
        let accountCodes = accounts.map { $0.currencyCode }
        let uniqueCodes = Set(accountCodes + [baseCurrencyCode])
        let currenciesToFetch = uniqueCodes.compactMap { CurrencyDataProvider.findCurrency(by: $0) }
        
        guard !currenciesToFetch.isEmpty else { return }
        
        await withCheckedContinuation { continuation in
            apiService.fetchRatesForCurrencies(currenciesToFetch, baseCurrency: baseCurrencyCode) { [weak self] result in
                switch result {
                case .success(let rates):
                    self?.saveRates(rates)
                case .failure(let error):
                    print("Rates update failed: \(error)")
                }
                continuation.resume()
            }
        }
    }
    
    func refreshRatesIfNeeded(for accounts: [Account], baseCurrencyCode: String) async {
        if !needsRefresh && loadCachedRates() != nil {
            print("Rates are fresh, skipping network request")
            return
        }

        await refreshRates(for: accounts, baseCurrencyCode: baseCurrencyCode)
    }
    
    func convert(_ amount: Decimal, from fromCode: String, to toCode: String) -> Decimal {
        if fromCode == toCode { return amount }
        
        guard let rates = loadCachedRates() else { return 0 }
        
        let amountInUSD: Decimal
        if fromCode == "USD" {
            amountInUSD = amount
        } else {
            guard let fromRate = rates[fromCode], fromRate > 0 else { return 0 }
            
            let isCrypto = CurrencyDataProvider.findCurrency(by: fromCode)?.type == .crypto
            amountInUSD = isCrypto ? amount * Decimal(fromRate) : amount / Decimal(fromRate)
        }
        
        if toCode == "USD" {
            return amountInUSD
        } else {
            guard let toRate = rates[toCode], toRate > 0 else { return amountInUSD }
            let isTargetCrypto = CurrencyDataProvider.findCurrency(by: toCode)?.type == .crypto
            return isTargetCrypto ? amountInUSD / Decimal(toRate) : amountInUSD * Decimal(toRate)
        }
    }

    // MARK: - Local Data Logic
    
    static func detectUserCurrency() -> String {
        let userLocale = Locale.current
        if let currencyCode = userLocale.currency?.identifier {
            return currencyCode
        }
        if let regionCode = userLocale.region?.identifier {
            return getCurrencyForRegion(regionCode)
        }
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
        guard let code = code else { return "$" }
        return getCurrency(for: code).symbol
    }
    
    static func getCurrency(for code: String) -> Currency {
        return CurrencyDataProvider.findCurrency(by: code) ?? .defaultUSD
    }
    
    static func getCurrencyIcon(for currency: Currency) -> String {
        return currency.code.uppercased()
    }

    // MARK: - Persistence
    
    var needsRefresh: Bool {
        guard let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastUpdate) > 21600
    }
    
    private func saveRates(_ rates: [String: Double]) {
        if let data = try? JSONEncoder().encode(rates) {
            userDefaults.set(data, forKey: lastRatesKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        }
    }
    
    func loadCachedRates() -> [String: Double]? {
        guard let data = userDefaults.data(forKey: lastRatesKey) else { return nil }
        return try? JSONDecoder().decode([String: Double].self, from: data)
    }
}
