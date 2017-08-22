//
//  ShapeShiftAPIClient.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class ShapeShiftAPIClient
{
    // Internal
    internal var apiKey: String?
    
    // Fileprivate
    fileprivate let baseURL = URL(string: "https://shapeshift.io")!
    
    // Private
    private let session: URLSession
    
    // MARK: Initialization
    
    internal required init(session: URLSession = URLSession(configuration: .default))
    {
        self.session = session
    }
    
    // MARK: Request
    
    fileprivate func perform(request: URLRequest, completionHandler: @escaping (_ json: [String : Any]?, _ data: Data?, _ response: HTTPURLResponse, _ error: Error?) -> Void)
    {
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] else
            {
                completionHandler(nil, data, httpResponse, APIError.invalidJSON)
                return
            }
            
            completionHandler(json, data, httpResponse, error)
        }
        
        task.resume()
    }
}

// MARK: Available coins

internal extension ShapeShiftAPIClient
{
    internal func fetchSupportedCoins(_ completionHandler: @escaping (_ coins: [Coin]?, _ error: APIError?) -> Void)
    {
        let requestPath = "/getcoins"
        let url = self.baseURL.appendingPathComponent(requestPath)
        let request = URLRequest(url: url)
        
        // Perform request
        self.perform(request: request) { (json, data, response, error) in
            guard let unwrappedJSON = json else
            {
                return
            }
            
            // Handle response
            if response.isSuccess
            {
                guard let coinsJSON = unwrappedJSON as? [String : [String : Any]] else
                {
                    // return invalid json
                    fatalError()
                }
                
                // Build coins
                var coins = [Coin]()
                for (_, coinJSON) in coinsJSON
                {
                    do
                    {
                        let coin = try Coin(dictionary: coinJSON)
                        coins.append(coin)
                    }
                    catch { }
                }
                
                completionHandler(coins, nil)
            }
            else
            {
                let error = APIError.response(httpResponse: response, data: data)
                completionHandler(nil, error)
            }
        }
    }
}

// MARK: Market Information

internal extension ShapeShiftAPIClient
{
    internal func fetchMarketInformation(for coinPair: CoinPair, completionHandler: @escaping (_ marketInformation: MarketInformation?, _ error: Error?) -> Void)
    {
        let requestPath = "/marketinfo/\(coinPair.code)"
        let url = self.baseURL.appendingPathComponent(requestPath)
        let request = URLRequest(url: url)
        
        self.perform(request: request) { (json, data, response, error) in
            if !response.isSuccess
            {
                let error = APIError.response(httpResponse: response, data: data)
                completionHandler(nil, error)
                return
            }
            
            guard let unwrappedJSON = json else
            {
                completionHandler(nil, APIError.invalidJSON)
                return
            }
            
            do
            {
                let marketInformation = try MarketInformation(coinPair: coinPair, dictionary: unwrappedJSON)
                completionHandler(marketInformation, nil)
            }
            catch let error
            {
                completionHandler(nil, error)
            }
        }
    }
}

// MARK: Send amount

internal extension ShapeShiftAPIClient
{
    internal func createTransaction(amount: Double, recipientAddress: String, pairCode: String, returnAddress: String? = nil, completionHandler: @escaping (_ transactionRequest: TransactionRequest?, _ error: Error?) -> Void)
    {
        // Body
        var bodyJSON: [String : Any] = [
            "withdrawal" : recipientAddress,
            "amount" : amount,
            "pair" : pairCode
        ]
        
        if let unwrappedReturnAddress = returnAddress
        {
            bodyJSON["returnAddress"] = unwrappedReturnAddress
        }

        if let unwrappedAPIKey = self.apiKey
        {
            bodyJSON["apiKey"] = unwrappedAPIKey
        }
        
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        
        // Request
        let requestPath = "/sendamount"
        let url = self.baseURL.appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        self.perform(request: request) { (json, data, response, error) in
            guard let transactionRequestJSON = json?["success"] as? [String : Any] else
            {
                let error = APIError.response(httpResponse: response, data: data)
                completionHandler(nil, error)
                return
            }
            
            do
            {
                let transactionRequest = try TransactionRequest(dictionary: transactionRequestJSON)
                completionHandler(transactionRequest, nil)
            }
            catch let error
            {
                completionHandler(nil, error)
            }
        }
    }
}

// MARK: Quote

internal extension ShapeShiftAPIClient
{
    internal func fetchQuote(amount: Double, pairCode: String, completionHandler: @escaping (_ quote: Quote?, _ error: Error?) -> Void)
    {
        // Body
        let bodyJSON: [String : Any] = [
            "amount" : amount,
            "pair" : pairCode
        ]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        
        // Request
        let requestPath = "/sendamount"
        let url = self.baseURL.appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        self.perform(request: request) { (json, data, response, error) in
            guard let quoteJSON = json?["success"] as? [String : Any] else
            {
                let error = APIError.response(httpResponse: response, data: data)
                completionHandler(nil, error)
                return
            }
            
            do
            {
                let quote = try Quote(dictionary: quoteJSON)
                completionHandler(quote, nil)
            }
            catch let error
            {
                completionHandler(nil, error)
            }
        }
    }
}
