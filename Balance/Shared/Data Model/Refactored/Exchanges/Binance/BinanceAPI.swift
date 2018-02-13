//
//  BinanceAPI.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BinanceAPI: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .simpleHmacSha256 }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.query
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts:
            guard let urlWithoutSignature = action.url,
                let messageSigned = generateMessageSigned(for: action),
                let url = urlWithoutSignature.addQueryParams(["signature": messageSigned]) else {
                return nil
            }
            
            return createRequest(from: action, with: url)
        default:
            return nil
        }
    }
    
    override func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        switch action.type {
        case .accounts:
            guard let singleRequest = createRequest(for: action) else {
                return nil
            }
            
            return ExchangeOperation(with: self, action: action, request: singleRequest, resultBlock: completion)
        case .transactions(_):
            let transactionSyncer = ExchangeTransactionDataSyncer()
            
            return ExchangeTransactionOperation(action: action,
                                                dataSyncer: transactionSyncer,
                                                requestBuilder: self,
                                                responseHandler: self,
                                                resultBlock: completion)
        }
    }
    
    override func buildAccounts(from data: Data) -> Any {
        do {
            let accounts = try JSONDecoder().decode(BinanceAccounts.self, from: data)
            
            return accounts.balances
        } catch {
            print("Accounts from hitbtc can not be parsed to an object\n\(error)")
            return []
        }
    }
    
    override func buildTransactions(from data: Data) -> Any {
        do {
            let deposit = try JSONDecoder().decode(BinanceDepositList.self, from: data)
            
            return deposit.depositList.filter { $0.status == .success }
        } catch {
            print("Deposits from binance can not be parsed to an object\n\(error)")
        }
        
        do {
            let withdrawal = try JSONDecoder().decode(BinanceWithdrawalList.self, from: data)
            
            return withdrawal.withdrawList.filter { $0.status == .completed }
        } catch {
            print("Withdrawal from binance can not be parsed to an object\n\(error)")
        }
        
        return []
    }
    
    override func processBaseErrors(data: Data?, error: Error?, response: URLResponse?) -> Error? {
        guard let data = data,
            let response = response as? HTTPURLResponse,
            let dict = createDict(from: data) else {
                return nil
        }
        
        guard let code = dict["code"] as? Int,
            let message = dict["msg"] as? String else {
                return nil
        }
        
        let statusCode = response.statusCode
        
        switch code {
        case -1002:
            return ExchangeBaseError.scopeRestricted
        case -1022:
            return ExchangeBaseError.invalidCredentials(statusCode: statusCode)
        default:
            return statusCode > 500 ? ExchangeBaseError.invalidServer(statusCode: statusCode) :
                ExchangeBaseError.other(message: message)
        }
    }

    //Errors come over the http protocol not throght 200 status code
    override func processApiErrors(from data: Data) -> Error? {
        return nil
    }
    
}

private extension BinanceAPI {
    
    func createRequest(from action: APIAction, with url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.timeoutInterval = 5000
        request.setValue(action.credentials.apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
        
        return request
    }
    
}

extension BinanceAPI: ExchangeTransactionRequest {
    
    func createTransactionAction(from action: APIAction) -> APIAction {
        return BinanceAPIAction(type: action.type, credentials: action.credentials)
    }
    
    func createRequest(with action: APIAction, for transactionType: ExchangeTransactionType) -> URLRequest? {
        guard let binanceAction = action as? BinanceAPIAction,
            case .transactions(_) = binanceAction.type else {
            return nil
        }
        
        let actionURL =  transactionType == .deposit ?
            binanceAction.depositTransactionURL : binanceAction.withdrawalTransactionURL
        
        guard let urlWithoutSignature = actionURL,
            let query = urlWithoutSignature.query else {
            return nil
        }
        
        let messageSigned = CryptoAlgorithm.sha256.hmac(body: query,
                                                        key: action.credentials.secretKey)
        
        guard let url = urlWithoutSignature.addQueryParams(["signature": messageSigned]) else {
            return nil
        }
        
        return createRequest(from: action, with: url)
    }
    
}

//TODO: delete the code below(When new interface is done)
extension BinanceAPI: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //Not needed when the new refactor has been finished!!!!
    }
    
}
