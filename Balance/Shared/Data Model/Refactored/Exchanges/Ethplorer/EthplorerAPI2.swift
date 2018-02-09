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
        guard let data = prepareAccountData(from: data),
            let accounts = try? JSONDecoder().decode([EthplorerAccount2].self, from: data) else {
            return ExchangeBaseError.other(message: "malformed data payload")
        }
        
        return accounts
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
            let ethDict = dict["ETH"], let address = dict["address"],
            let tokens = dict["tokens"] as? [[String: AnyObject]] else {
                return nil
        }

        let flatDict = tokens.map { (tokenInfo) -> [String: AnyObject] in
            var token = tokenInfo
            token["ETH"] = ethDict
            token["address"] = address
            return token
        }
        
        return try? JSONSerialization.data(withJSONObject: flatDict, options: .prettyPrinted)
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
