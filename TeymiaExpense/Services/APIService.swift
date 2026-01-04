import Foundation

/// Service responsible for fetching currency exchange rates from external APIs
/// - Fiat currencies: ExchangeRate API
/// - Cryptocurrencies: CoinGecko API
class APIService {
    static let shared = APIService()
    
    // MARK: - API Endpoints
    
    private let fiatBaseURL = "https://api.exchangerate-api.com/v4"
    private let cryptoBaseURL = "https://api.coingecko.com/api/v3"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Fetches exchange rates for both fiat and crypto currencies
    /// - Parameters:
    ///   - currencies: Array of currencies to fetch rates for
    ///   - baseCurrency: Base currency for conversion (default: USD)
    ///   - completion: Completion handler with result containing currency rates
    func fetchRatesForCurrencies(
        _ currencies: [Currency],
        baseCurrency: String = "USD",
        completion: @escaping (Result<[String: Double], Error>) -> Void
    ) {
        let fiatCurrencies = currencies.filter { $0.type == .fiat }.map { $0.code }
        let cryptoCurrencies = currencies.filter { $0.type == .crypto }.map { $0.code }
        
        let group = DispatchGroup()
        var combinedRates: [String: Double] = [:]
        var errors: [Error] = []
        
        // Always include base currency rate
        if fiatCurrencies.contains(baseCurrency) || cryptoCurrencies.contains(baseCurrency) {
            combinedRates[baseCurrency] = 1.0
        }
        
        // Fetch fiat rates
        if !fiatCurrencies.isEmpty {
            group.enter()
            fetchMultipleFiatRates(from: baseCurrency, to: fiatCurrencies) { result in
                defer { group.leave() }
                switch result {
                case .success(let rates):
                    combinedRates.merge(rates) { _, new in new }
                case .failure(let error):
                    errors.append(error)
                }
            }
        }
        
        // Fetch crypto rates
        if !cryptoCurrencies.isEmpty {
            group.enter()
            fetchCryptoRates(targetCurrencies: cryptoCurrencies) { result in
                defer { group.leave() }
                switch result {
                case .success(let rates):
                    combinedRates.merge(rates) { _, new in new }
                case .failure(let error):
                    errors.append(error)
                }
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty && combinedRates.isEmpty {
                completion(.failure(errors.first!))
            } else {
                completion(.success(combinedRates))
            }
        }
    }
    
    // MARK: - Fiat Currency Methods
    
    /// Fetches fiat currency rates from ExchangeRate API
    /// - Parameters:
    ///   - baseCurrency: Base currency code (e.g., "USD")
    ///   - completion: Completion handler with exchange rates
    private func fetchFiatRates(
        baseCurrency: String = "USD",
        completion: @escaping (Result<FiatExchangeResponse, Error>) -> Void
    ) {
        let urlString = "\(fiatBaseURL)/latest/\(baseCurrency)"
        performRequest(urlString: urlString, completion: completion)
    }
    
    /// Fetches rates for specific fiat currencies
    /// - Parameters:
    ///   - baseCurrency: Base currency code
    ///   - targetCurrencies: Array of target currency codes
    ///   - completion: Completion handler with filtered rates
    private func fetchMultipleFiatRates(
        from baseCurrency: String,
        to targetCurrencies: [String],
        completion: @escaping (Result<[String: Double], Error>) -> Void
    ) {
        fetchFiatRates(baseCurrency: baseCurrency) { result in
            switch result {
            case .success(let response):
                let filteredRates = response.rates.filter { targetCurrencies.contains($0.key) }
                completion(.success(filteredRates))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Crypto Currency Methods
    
    /// Fetches cryptocurrency rates from CoinGecko API
    /// - Parameters:
    ///   - targetCurrencies: Array of crypto currency codes (e.g., ["BTC", "ETH"])
    ///   - vsCurrency: Fiat currency to compare against (default: "usd")
    ///   - completion: Completion handler with crypto rates
    private func fetchCryptoRates(
        targetCurrencies: [String],
        vsCurrency: String = "usd",
        completion: @escaping (Result<[String: Double], Error>) -> Void
    ) {
        // Convert currency codes to CoinGecko IDs
        let coinIds = targetCurrencies.compactMap { cryptoCodeToCoinGeckoId($0) }
        
        guard !coinIds.isEmpty else {
            completion(.success([:]))
            return
        }
        
        let idsString = coinIds.joined(separator: ",")
        let urlString = "\(cryptoBaseURL)/simple/price?ids=\(idsString)&vs_currencies=\(vsCurrency)"
        
        performRequest(urlString: urlString) { (result: Result<CryptoExchangeResponse, Error>) in
            switch result {
            case .success(let response):
                var rates: [String: Double] = [:]
                
                for (coinId, priceData) in response {
                    if let cryptoCode = self.coinGeckoIdToCryptoCode(coinId),
                       let price = priceData[vsCurrency] {
                        rates[cryptoCode] = price
                    }
                }
                
                completion(.success(rates))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Network Layer
    
    /// Performs a generic network request and decodes the response
    /// - Parameters:
    ///   - urlString: URL string for the request
    ///   - completion: Completion handler with decoded response
    private func performRequest<T: Codable>(
        urlString: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    let error = NSError(
                        domain: "APIService",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"]
                    )
                    completion(.failure(error))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Currency Code Mapping
    
    /// Converts currency code to CoinGecko API ID
    /// - Parameter code: Currency code (e.g., "BTC")
    /// - Returns: CoinGecko ID (e.g., "bitcoin") or nil if not found
    private func cryptoCodeToCoinGeckoId(_ code: String) -> String? {
        let mapping: [String: String] = [
            "AAVE": "aave",
            "ADA": "cardano",
            "ALGO": "algorand",
            "APT": "aptos",
            "ARB": "arbitrum",
            "ATOM": "cosmos",
            "AVAX": "avalanche-2",
            "AXS": "axie-infinity",
            "BCH": "bitcoin-cash",
            "BGB": "bitget-token",
            "BNB": "binancecoin",
            "BTC": "bitcoin",
            "BUSD": "binance-usd",
            "CFX": "conflux-token",
            "CRO": "crypto-com-chain",
            "DAI": "dai",
            "DOGE": "dogecoin",
            "DOT": "polkadot",
            "EGLD": "elrond-erd-2",
            "ETC": "ethereum-classic",
            "ETH": "ethereum",
            "FIL": "filecoin",
            "FLR": "flare-networks",
            "GRT": "the-graph",
            "HBAR": "hedera-hashgraph",
            "ICP": "internet-computer",
            "INJ": "injective-protocol",
            "JLP": "jupiter-exchange-solana",
            "KAS": "kaspa",
            "LDO": "lido-dao",
            "LEO": "leo-token",
            "LINK": "chainlink",
            "LTC": "litecoin",
            "LUNC": "terra-luna-classic",
            "METH": "mantle-staked-ether",
            "NEAR": "near",
            "OP": "optimism",
            "POL": "matic-network",
            "PYTH": "pyth-network",
            "QNT": "quant-network",
            "RENDER": "render-token",
            "SEI": "sei-network",
            "SHIB": "shiba-inu",
            "SOL": "solana",
            "STETH": "staked-ether",
            "STX": "blockstack",
            "SUI": "sui",
            "TAO": "bittensor",
            "THETA": "theta-token",
            "TIA": "celestia",
            "TON": "the-open-network",
            "TRX": "tron",
            "UNI": "uniswap",
            "USDC": "usd-coin",
            "USDT": "tether",
            "VET": "vechain",
            "WBT": "whitebit",
            "WBTC": "wrapped-bitcoin",
            "XLM": "stellar",
            "XMR": "monero",
            "XRP": "ripple",
            "XTZ": "tezos",
            "ZEC": "zcash"
        ]
        
        return mapping[code]
    }
    
    /// Converts CoinGecko API ID back to currency code
    /// - Parameter id: CoinGecko ID (e.g., "bitcoin")
    /// - Returns: Currency code (e.g., "BTC") or nil if not found
    private func coinGeckoIdToCryptoCode(_ id: String) -> String? {
        let mapping: [String: String] = [
            "aave": "AAVE",
            "cardano": "ADA",
            "algorand": "ALGO",
            "aptos": "APT",
            "arbitrum": "ARB",
            "cosmos": "ATOM",
            "avalanche-2": "AVAX",
            "axie-infinity": "AXS",
            "bitcoin-cash": "BCH",
            "bitget-token": "BGB",
            "binancecoin": "BNB",
            "bitcoin": "BTC",
            "binance-usd": "BUSD",
            "conflux-token": "CFX",
            "crypto-com-chain": "CRO",
            "dai": "DAI",
            "dogecoin": "DOGE",
            "polkadot": "DOT",
            "elrond-erd-2": "EGLD",
            "ethereum-classic": "ETC",
            "ethereum": "ETH",
            "filecoin": "FIL",
            "flare-networks": "FLR",
            "the-graph": "GRT",
            "hedera-hashgraph": "HBAR",
            "internet-computer": "ICP",
            "injective-protocol": "INJ",
            "jupiter-exchange-solana": "JLP",
            "kaspa": "KAS",
            "lido-dao": "LDO",
            "leo-token": "LEO",
            "chainlink": "LINK",
            "litecoin": "LTC",
            "terra-luna-classic": "LUNC",
            "mantle-staked-ether": "METH",
            "near": "NEAR",
            "optimism": "OP",
            "matic-network": "POL",
            "pyth-network": "PYTH",
            "quant-network": "QNT",
            "render-token": "RENDER",
            "sei-network": "SEI",
            "shiba-inu": "SHIB",
            "solana": "SOL",
            "staked-ether": "STETH",
            "blockstack": "STX",
            "sui": "SUI",
            "bittensor": "TAO",
            "theta-token": "THETA",
            "celestia": "TIA",
            "the-open-network": "TON",
            "tron": "TRX",
            "uniswap": "UNI",
            "usd-coin": "USDC",
            "tether": "USDT",
            "vechain": "VET",
            "whitebit": "WBT",
            "wrapped-bitcoin": "WBTC",
            "stellar": "XLM",
            "monero": "XMR",
            "ripple": "XRP",
            "tezos": "XTZ",
            "zcash": "ZEC"
        ]
        
        return mapping[id]
    }
}

// MARK: - Response Models

/// Response model for fiat currency exchange rates
struct FiatExchangeResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
}

/// Response model for cryptocurrency exchange rates
/// Format: {"bitcoin": {"usd": 45000}}
typealias CryptoExchangeResponse = [String: [String: Double]]
