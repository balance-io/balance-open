//
//  EthplorerAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/1/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class EthplorerAPI2: AbstractApi{
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .none }
    override var encondingMessageType: ApiEncondingMessageType { return .none }
    override var requestHandler: RequestHandler? { return self }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts, .transactions:
            guard let url = action.url else {
                    print("Invalid action: \(action.type), for creating Ethplorer request")
                    return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            return request
        }
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let errorMessage = dict["error"] as? String else {
            return nil
        }
        
        return ExchangeBaseError.other(message: errorMessage)
    }
    
    override func buildAccounts(from data: Data) -> Any {
        guard let rawData = prepareAccountData(from: data),
            let accounts = try? JSONDecoder().decode([EthplorerAccount2].self, from: rawData) else {
                return ExchangeBaseError.other(message: "malformed data payload")
        }
        
        return accountsWithEthtoken(accounts: accounts, data: data)
    }
    
    override func buildTransactions(from data: Data) -> Any {
        guard let transactions = try? JSONDecoder().decode([EthplorerTransaction2].self, from: data) else {
            return ExchangeBaseError.other(message: "malformed data payload")
        }
        return transactions
    }
    
}

private extension EthplorerAPI2 {
    func prepareAccountData(from data: Data) -> Data? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let tokens = dict["tokens"] as? [[String: Any]] else {
                return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: tokens, options: .prettyPrinted)
    }
    
    // Creates the ETH Token manually because the info of the ETH was outside of tokens array
    // that we passed to parse with codable, so we add the ETH info at the end
    func accountsWithEthtoken(accounts: [ExchangeAccount], data: Data) -> Any {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let ethDict = dict["ETH"] as? [String: AnyObject],
            let address = dict["address"] as? String,
            let balance = ethDict["balance"] as? Double else {
                return accounts
        }
        
        // Create tokenInfo dict for ETH token
        let ethInfo = EthplorerToken(address: address,
                                     name: Currency.eth.name,
                                     symbol: Currency.eth.code,
                                     decimals: Currency.eth.decimals,
                                     price: EthplorerPrice(rate: 1,
                                                           currency: .eth))
        
        // Create the ETH Account
//        let balanceInt = balance.integerValueWith(decimals: Currency.eth.decimals)
        let ethAccount = EthplorerAccount2(balance: balance,
                                           tokenInfo: ethInfo)
        
        // Make accounts array mutable
        var accounts = accounts
        accounts.insert(ethAccount, at: 0)
        
        // Return the full array with ETH token inside
        return accounts
    }
}

extension EthplorerAPI2: RequestHandler {
    
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, ulrResponse: URLResponse?) -> Any {
        guard let action = action else {
            return ExchangeBaseError.other(message: "No action provided")
        }
        
        if let error = processErrors(response: ulrResponse, data: data, error: error) {
            return error
        }
        
        return processData(requestType: action.type, data: data)
    }

}
