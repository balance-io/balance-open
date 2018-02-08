//
//  BITTREXAPI2TransactionSyncer.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/7/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BITTREXAPI2TransactionType {
    case deposit
    case withdrawal
}

protocol BITTREXAPI2TransactionDataDelegate: class {
    func process(deposits: Any, withdrawals: Any)
}

protocol BITTREXAPI2TransactionRequest: class {
    func createRequest(action: APIAction ,transactionType: BITTREXAPI2TransactionType) -> URLRequest?
}

struct BITTREXAPI2SyncerTransaction {
    
    private let maxNumberOfCalls: Int = 2
    
    private var numberOfCalls: Int = 0 {
        didSet {
            guard numberOfCalls == maxNumberOfCalls else {
                return
            }
            
            dataDelegate?.process(deposits: deposits, withdrawals: withdraws)
        }
    }
    
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
            return
        }
        
        numberOfCalls += 1
    }
    
}

class BITTREXAPI2TransactionOperation: Operation, BITTREXAPI2TransactionDataDelegate {
    
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
        
        let task = session.dataTask(with: depositRequest) { (data, response, error) in
            //TODO: process data and set it on dataSyncer Property, error can be setted too becuase property is Any type
            //data dataSyncer.deposits = <DATA PROCESSED>
        }
        
        task.resume()
    }
    
    func fetchWithdrawals() {
        let bittrexWithdrawalAction =  BITTREXAPI2Action(type: .transactions(input: nil), credentials: action.credentials)
        guard let withdrawalRequest = requestBuilder.createRequest(action: bittrexWithdrawalAction, transactionType: .withdrawal) else {
            dataSyncer.withdraws = []
            return
        }
        
        let task = session.dataTask(with: withdrawalRequest) { (data, response, error) in
            //TODO: process data and set it on dataSyncer Property, error can be setted too becuase property is Any type
            //data dataSyncer.withdraws = <DATA PROCESSED>
        }
        
        task.resume()
    }
    
}

