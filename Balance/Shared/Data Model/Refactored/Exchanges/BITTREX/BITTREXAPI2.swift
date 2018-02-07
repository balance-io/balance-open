//
//  BITTREXAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

fileprivate typealias bittrexTransactionRequest = (depositRequest: URLRequest, withdrawalRequest: URLRequest)

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
            guard let transactionRequests = createMultipleTransactionRequests(for: action) else {
                return nil
            }
            
            let transactionRequestManager = BITTREXAPI2Transactions(requests: transactionRequests)
            //TODO: insert handler respose(parser delegate) into the operation
            return BITTREXAPI2TransactionOperation(transactionsRequest: transactionRequestManager)
        }
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts:
            guard let url = action.url,
                let messageSigned = generateMessageSigned(for: action) else {
                    return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            request.setValue(messageSigned, forHTTPHeaderField: "apisign")

            return request
        default:
            return nil
        }
    }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.url?.absoluteString
    }
    
}

private extension BITTREXAPI2 {
    
    func createMultipleTransactionRequests(for action: APIAction) -> bittrexTransactionRequest? {
        guard let bittrexAction = action as? BITTREXAPI2Action,
            let urls = bittrexAction.transactionURLs else {
            return nil
        }
        
        let depositMessageSigned = CryptoAlgorithm.sha512.hmac(body: urls.deposits.absoluteString, key: action.credentials.secretKey)
        let withdrawalMessageSigned = CryptoAlgorithm.sha512.hmac(body: urls.deposits.absoluteString, key: action.credentials.secretKey)
        
        var depositRequest = URLRequest(url: urls.deposits)
        depositRequest.httpMethod = requestMethod.rawValue
        depositRequest.setValue(depositMessageSigned, forHTTPHeaderField: "apisign")
        
        var withdrawalRequest = URLRequest(url: urls.withdrawals)
        withdrawalRequest.httpMethod = requestMethod.rawValue
        withdrawalRequest.setValue(withdrawalMessageSigned, forHTTPHeaderField: "apisign")
        
        return (depositRequest, withdrawalRequest)
    }
    
}

protocol BITTREXAPI2TransactionDataDelegate: class {
    func process(deposits: [BITTREXDeposit], withdrawals: [BITTREXWithdrawal])
}

fileprivate struct BITTREXAPI2Transactions {
    
    let depositRequest: URLRequest
    let withdrawalRequest: URLRequest
    
    private var numberOfCalls: Int = 0
    private let maxNumberOfCalls: Int = 2
    
    var deposits: [BITTREXDeposit] = [] {
        didSet {
            incrementCalls()
        }
    }
    
    var withdraws: [BITTREXWithdrawal] = [] {
        didSet {
            incrementCalls()
        }
    }
    
    weak var delegate: BITTREXAPI2TransactionDataDelegate?
    
    init(requests: bittrexTransactionRequest) {
        self.depositRequest = requests.depositRequest
        self.withdrawalRequest = requests.withdrawalRequest
    }
    
    mutating func incrementCalls() {
        guard numberOfCalls < maxNumberOfCalls else {
            delegate?.process(deposits: deposits, withdrawals: withdraws)
            return
        }
        
        numberOfCalls += 1
    }
    
}

fileprivate class BITTREXAPI2TransactionOperation: Operation, BITTREXAPI2TransactionDataDelegate {
    
    private var transactionsRequest: BITTREXAPI2Transactions
    
    init(transactionsRequest: BITTREXAPI2Transactions) {
        self.transactionsRequest = transactionsRequest
        super.init()
        self.transactionsRequest.delegate = self
    }
    
    func process(deposits: [BITTREXDeposit], withdrawals: [BITTREXWithdrawal]) {
        //TODO: call callback
    }
    
}
