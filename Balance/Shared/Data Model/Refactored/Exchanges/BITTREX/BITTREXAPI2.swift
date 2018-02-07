//
//  BITTREXAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BITTREXAPI2: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .simpleHmacSha512 }
    
    override func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        switch action.type {
        case .accounts :
            guard let singleRequest = createRequest(for: action) else {
                return nil
            }
            
            //TODO: use normal operation
            print(singleRequest)
            return nil
        case .transactions(_):
            
            let transactionSyncer = BITTREXAPI2SyncerTransaction()
            //TODO: insert handler respose(parser delegate) into the operation
            return BITTREXAPI2TransactionOperation(action: action, dataSyncer: transactionSyncer, requestBuilder: self)
        }
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts:
            guard let url = action.url,
                let messageSigned = generateMessageSigned(for: action) else {
                    return nil
            }

            return createRequest(url: url, credentials: action.credentials, messageSigned: messageSigned)
        default:
            return nil
        }
    }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.url?.absoluteString
    }
    
}

extension BITTREXAPI2: BITTREXAPI2TransactionRequest {
    
    func createRequest(action: APIAction, transactionType: BITTREXAPI2TransactionType) -> URLRequest? {
        guard let bittrexAction = action as? BITTREXAPI2Action,
            case .transactions(_) = bittrexAction.type else {
            return nil
        }
        
        let url = transactionType == .deposit ? bittrexAction.depositTransactionURL : bittrexAction.withdrawalTransactionURL
        
        guard let transactionURL = url else {
            return nil
        }
        
        let messageSigned = CryptoAlgorithm.sha512.hmac(body: transactionURL.absoluteString, key: action.credentials.secretKey)
    
        return createRequest(url: transactionURL, credentials: action.credentials, messageSigned: messageSigned)
    }
    
    private func createRequest(url: URL, credentials: Credentials, messageSigned: String) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.setValue(messageSigned, forHTTPHeaderField: "apisign")

        return (request)
    }
    
}


fileprivate protocol BITTREXAPI2TransactionDataDelegate: class {
    func process(deposits: Any, withdrawals: Any)
}

enum BITTREXAPI2TransactionType {
    case deposit
    case withdrawal
}

fileprivate protocol BITTREXAPI2TransactionRequest: class {
    func createRequest(action: APIAction ,transactionType: BITTREXAPI2TransactionType) -> URLRequest?
}

fileprivate struct BITTREXAPI2SyncerTransaction {
    
    private var numberOfCalls: Int = 0
    private let maxNumberOfCalls: Int = 2
    
    var deposits: Any = [] {
        didSet {
            incrementCalls()
        }
    }
    
    var withdraws: Any = [] {
        didSet {
            incrementCalls()
        }
    }
    
    weak var dataDelegate: BITTREXAPI2TransactionDataDelegate?
    
    mutating func incrementCalls() {
        guard numberOfCalls < maxNumberOfCalls else {
            dataDelegate?.process(deposits: deposits, withdrawals: withdraws)
            return
        }
        
        numberOfCalls += 1
    }
    
}

fileprivate class BITTREXAPI2TransactionOperation: Operation, BITTREXAPI2TransactionDataDelegate {
    
    private var dataSyncer: BITTREXAPI2SyncerTransaction
    private let requestBuilder: BITTREXAPI2TransactionRequest
    private let session: URLSession
    private let action: APIAction
    
    init(action: APIAction, dataSyncer: BITTREXAPI2SyncerTransaction, requestBuilder: BITTREXAPI2TransactionRequest, session: URLSession? = nil) {
        self.dataSyncer = dataSyncer
        self.requestBuilder = requestBuilder
        self.session = session ?? certValidatedSession
        self.action = action
        
        super.init()
        self.dataSyncer.dataDelegate = self
    }
    
    func process(deposits: Any, withdrawals: Any) {
        //TODO: call callback, check errors too, you can recive an array[BITTREXDeposit or BITTREXWithdrawal] or an error on each params
    }
    
    override func main() {
        fetchDeposits()
        async(after: 1) {
            self.fetchWithdrawals()
        }
    }
    
    func fetchDeposits() {
        guard let depositRequest = requestBuilder.createRequest(action: action, transactionType: .deposit) else {
            dataSyncer.deposits = []
            return
        }
        
        session.dataTask(with: depositRequest) { (data, response, error) in
            //TODO: process data and set it on dataSyncer Property, error can be setted too becuase property is Any type
            //data dataSyncer.deposits = <DATA PROCESSED>
        }
    }
    
    func fetchWithdrawals() {
        guard let withdrawalRequest = requestBuilder.createRequest(action: action, transactionType: .withdrawal) else {
            dataSyncer.withdraws = []
            return
        }
        
        session.dataTask(with: withdrawalRequest) { (data, response, error) in
            //TODO: process data and set it on dataSyncer Property, error can be setted too becuase property is Any type
            //data dataSyncer.withdraws = <DATA PROCESSED>
        }
    }
    
}
