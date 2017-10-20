//
//  CurrentExchangeRates.swift
//  Balance
//
//  Created by Benjamin Baron on 10/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class CurrentExchangeRates {
    struct Notifications {
        static let exchangeRatesUpdated = Notification.Name("exchangeRatesUpdated")
    }
    
    fileprivate let exchangeRatesUrl = URL(string: "https://balance-server.appspot.com/exchangeRates")!
    
    fileprivate let cache = SimpleCache<ExchangeRateSource, [ExchangeRate]>()
    fileprivate let persistedFileName = "currentExchangeRates.data"
    fileprivate var persistedFileUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(persistedFileName)
    }
    
    func exchangeRates(forSource source: ExchangeRateSource) -> [ExchangeRate]? {
        return cache.get(valueForKey: source)
    }
    
    func convert(amount: Int, from: Currency, to: Currency, source: ExchangeRateSource) -> Int? {
        let doubleAmount = Double(amount) / pow(10, Double(from.decimals))
        if let doubleConvertedAmount = convert(amount: doubleAmount, from: from, to: to, source: source) {
            let intConvertedAmount = Int(doubleConvertedAmount * pow(10, Double(to.decimals)))
            return intConvertedAmount
        }
        return nil
    }
    
    public func convert(amount: Double, from: Currency, to: Currency, source: ExchangeRateSource) -> Double? {
        var rate: Double?
        
        if let newRate = directConvert(amount: amount, from: from, to: to, source: source) {
            return newRate
        }
        for source in ExchangeRateSource.all {
            if let newRate = directConvert(amount: amount, from: from, to: to, source: source) {
                rate = newRate
            }
            if rate != nil {
                return rate!
            } else {
                //change currency and loop through all sources to get a connecting currency to use as middle point
                for currency in source.mainCurrencies {
                    var fromRate: Double? = directConvert(amount: amount, from: from, to: currency, source: source)
                    var toRate: Double? = directConvert(amount: amount, from: currency, to: to, source: source)
                    for source in ExchangeRateSource.all {
                        if currency == from || currency == to {
                            continue
                        }
                        if fromRate == nil, let newfromRate = directConvert(amount: amount, from: from, to: currency, source: source) {
                            fromRate = newfromRate
                        }
                        
                        if toRate == nil, let newtoRate = directConvert(amount: amount, from: currency, to: to, source: source) {
                            toRate = newtoRate
                        }
                        if fromRate != nil && toRate != nil {
                            return amount * fromRate! * toRate!
                        }
                    }
                }
            }
        }
        return nil
    }
    
    public func directConvert(amount: Double, from: Currency, to: Currency, source: ExchangeRateSource) -> Double? {
        
        log.debug("converting from \(from) to \(to) source \(source)")
        
        if let exchangeRates = exchangeRates(forSource: source) {
            // First check if the exact rate exists (either directly or reversed)
            if let rate = exchangeRates.rate(from: from, to: to) {
                log.debug("found direct conversion")
                return amount * rate
            } else if let rate = exchangeRates.rate(from: to, to: from) {
                log.debug("found direct reverse conversion")
                return amount * (1.0 / rate)
            }
        }
        
        return nil
    }
    
    func updateExchangeRates() {
        let task = certValidatedSession.dataTask(with: exchangeRatesUrl) { maybeData, maybeResponse, maybeError in
            // Make sure there's data
            guard let data = maybeData, maybeError == nil else {
                log.error("Error updating exchange rates, either no data or error: \(String(describing: maybeError))")
                return
            }
            
            // Parse and cache the data
            if self.parse(data: data) {
                self.persist(data: data)
                NotificationCenter.postOnMainThread(name: Notifications.exchangeRatesUpdated)
            }
        }
        task.resume()
    }
    
    @discardableResult func parse(data: Data) -> Bool {
        // Try to parse the JSON
        guard let tryExchangeRatesJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let exchangeRatesJson = tryExchangeRatesJson, exchangeRatesJson["code"] as? Int == BalanceError.success.rawValue else {
            log.error("Error parsing exchange rates, failed to parse json data")
            BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Failed to parse exchange rates")
            return false
        }
        
        // Parse the rates
        for (key, value) in exchangeRatesJson {
            // Ensure the exchange rate source is valid
            guard let sourceRaw = Int(key), let source = ExchangeRateSource(rawValue: sourceRaw) else {
                continue
            }
            
            // Ensure the value contains rates
            guard let value = value as? [String: Any], let rates = value["rates"] as? [[String: Any]] else {
                continue
            }
            
            // Parse the exchange rates
            var exchangeRates = [ExchangeRate]()
            for rateGroup in rates {
                if let from = rateGroup["from"] as? String, let to = rateGroup["to"] as? String, let rate = rateGroup["rate"] as? Double {
                    let exchangeRate = ExchangeRate(source: source, from: Currency.rawValue(from), to: Currency.rawValue(to), rate: rate)
                    exchangeRates.append(exchangeRate)
                }
            }
            
            // Cache the updated exchange rates
            if exchangeRates.count > 0 {
                self.cache.set(value: exchangeRates, forKey: source)
            }
        }
        
        return true
    }
    
    @discardableResult func persist(data: Data) -> Bool {
        do {
            try data.write(to: persistedFileUrl, options: .atomicWrite)
            return true
        } catch {
            log.error("Failed to persist current exchange rates: \(error)")
            return false
        }
    }
    
    @discardableResult func load() -> Bool {
        do {
            let data = try Data(contentsOf: persistedFileUrl)
            return parse(data: data)
        } catch {
            log.error("Failed to load current exchange rates from disk: \(error)")
            return false
        }
    }
}
