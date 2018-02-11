//
//  ExchangeTransactionOperation.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ExchangeTransactionRequest: class {
    func createRequest(with action: APIAction ,for transactionType: ExchangeTransactionType) -> URLRequest?
}

class ExchangeTransactionOperation: Operation, ExchangeTransactionDataDelegate {
    
    private var dataSyncer: ExchangeTransactionDataSyncer
    private let requestBuilder: ExchangeTransactionRequest
    private let session: URLSession
    private let action: APIAction
    
    init(action: APIAction,
         dataSyncer: ExchangeTransactionDataSyncer,
         requestBuilder: ExchangeTransactionRequest,
         session: URLSession? = nil)
    {
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
        guard let depositRequest = requestBuilder.createRequest(with: action, for: .deposit) else {
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
        guard let withdrawalRequest = requestBuilder.createRequest(with: bittrexWithdrawalAction, for: .withdrawal) else {
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
