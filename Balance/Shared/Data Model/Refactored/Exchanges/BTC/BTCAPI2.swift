//
//  BTCAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BTCAPI2: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .none }
    override var encondingMessageType: ApiEncondingMessageType { return .none }
    
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
        return nil
    }
    
    override func buildAccounts(from data: Data) -> Any {
        do {
            let accounts = try JSONDecoder().decode(BTCAccount2.self, from: data)
            return [accounts]
        } catch {
            print("error: \(error)")
            return ExchangeBaseError.other(message: "BTC accounts not available")
        }
    }
    
    override func buildTransactions(from data: Data) -> Any {
        // No transactions yet
        return []
    }
}
