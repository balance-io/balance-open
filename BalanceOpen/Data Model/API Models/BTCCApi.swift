//
//  BTCCApi.swift
//  BalanceOpen
//
//  Created by Sam Duke on 17/06/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

fileprivate let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
fileprivate let connectionTimeout = 30.0

class BTCCApi {

    private static let ACCESS_KEY = "ba15cd82-bf87-41a9-849e-13f59e751860"
    private static let SECRET_KEY = "31a7f190-daa9-463e-b5fa-1a90afeeeecc"
    
//    API Access Key : ba15cd82-bf87-41a9-849e-13f59e751860
//    
//    API Secret Key : 31a7f190-daa9-463e-b5fa-1a90afeeeecc
    private static let serverUrl = "https://api.btcchina.com/api_trade_v1.php"

    func getAccountInfo() {

        let currentTime = Date()
        let tonce = String(Int(currentTime.timeIntervalSince1970*1000))
        
        /// a BTCC Request must be signed in a specific way.
        /// The request being made must be summarised in a string and signed using the secret key
        /// It must then be included in the authorization field of the header as a base-64 encoded string

        // Order of params important
        let params = "tonce=\(tonce)&accesskey=\(BTCCApi.ACCESS_KEY)&requestmethod=post&id=1&method=getAccountInfo&params=[]"
        let hash = params.hmac(algorithm: .SHA1, key: BTCCApi.SECRET_KEY)
        let userpass = BTCCApi.ACCESS_KEY + ":" + hash
        guard let data = userpass.data(using: String.Encoding.utf8) else { return }
        let basicAuth = "Basic " + data.base64EncodedString()

        
        let postParams = "{\"method\": \"getAccountInfo\", \"params\": [], \"id\": 1}"

        let url = URL(string: BTCCApi.serverUrl)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        let parameters = postParams
        request.httpBody = parameters.data(using: .utf8)

        request.setValue(tonce, forHTTPHeaderField: "Json-Rpc-Tonce")
        request.setValue(basicAuth, forHTTPHeaderField: "Authorization")

        // TODO: Create enum types for each error
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw "No data"
                }

                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw "JSON decoding failed"
                }
                
                let resultDict: [String: AnyObject] = try checkType(JSONResult, name: "result")
                
                print(resultDict)
//
//                // Create the CoinbaseAccount objects
//                var coinbaseAccounts = [CoinbaseAccount]()
//                for accountDict in accountDicts {
//                    do {
//                        let coinbaseAccount = try CoinbaseAccount(account: accountDict)
//                        coinbaseAccounts.append(coinbaseAccount)
//                    } catch {
//                        log.error("Failed to parse account data: \(error)")
//                    }
//                }
//
//                // Create native Account objects and update them
//                self.processCoinbaseAccounts(coinbaseAccounts, institution: institution)
//
//                DispatchQueue.main.async {
//                    completion(true, nil)
//                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        })

        task.resume()
    }
}
