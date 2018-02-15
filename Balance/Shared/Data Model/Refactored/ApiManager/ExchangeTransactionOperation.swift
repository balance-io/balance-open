//
//  ExchangeTransactionOperation.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ExchangeTransactionRequest: class {
    func createTransactionAction(from action: APIAction) -> APIAction
    func createRequest(with action: APIAction ,for transactionType: ExchangeTransactionType) -> URLRequest?
}

class ExchangeTransactionOperation: Operation {
    
    override var isExecuting: Bool {
        return operatorIsExecuting
    }
    
    override var isFinished: Bool {
        return operatorHasFinished
    }
    
    override var isConcurrent: Bool {
        return false
    }
    
    private var dataSyncer: ExchangeTransactionDataSyncer
    private let requestBuilder: ExchangeTransactionRequest
    private let responseHandler: ResponseHandler
    private let session: URLSession
    private let action: APIAction
    private let resultBlock: ExchangeOperationCompletionHandler
    
    var operatorHasFinished: Bool = false {
        didSet{
            didChangeValue(forKey: "isFinished")
        }
        willSet{
            willChangeValue(forKey: "isFinished")
        }
    }
    
    var operatorIsExecuting: Bool = false {
        didSet{
            didChangeValue(forKey: "isExecuting")
        }
        willSet{
            willChangeValue(forKey: "isExecuting")
        }
    }
    
    init(action: APIAction,
         dataSyncer: ExchangeTransactionDataSyncer,
         requestBuilder: ExchangeTransactionRequest,
         responseHandler: ResponseHandler,
         session: URLSession? = nil,
         resultBlock: @escaping ExchangeOperationCompletionHandler)
    {
        self.dataSyncer = dataSyncer
        self.requestBuilder = requestBuilder
        self.responseHandler = responseHandler
        self.resultBlock = resultBlock
        self.session = session ?? certValidatedSession
        self.action = action
        
        super.init()
        self.dataSyncer.dataDelegate = self
    }
    
    override func start() {
        if isCancelled {
            operatorHasFinished = true
            return
        }
        
        operatorIsExecuting = true
        main()
    }
    
    override func main() {
        if isCancelled {
            taskFinished()
            return
        }
        
        fetchDeposits()
        async(after: 1) {
            self.fetchWithdrawals()
        }
    }
    
}

extension ExchangeTransactionOperation: ExchangeTransactionDataDelegate {
    
    func process(deposits: Any, withdrawals: Any) {
        if isCancelled {
            self.taskFinished()
        }
        
        completionBlock?()
        
        if let deposits = deposits as? [ExchangeTransaction],
            let withdrawals = withdrawals as? [ExchangeTransaction] {
            
            let deposits = deposits.map { (tx) -> ExchangeTransaction in
                var deposit = tx
                deposit.type = "deposit"
                return deposit
            }
            
            let withdrawals = withdrawals.map { (tx) -> ExchangeTransaction in
                var withdrawal = tx
                withdrawal.type = "withdrawal"
                return withdrawal
            }
            
            resultBlock(true, nil, deposits + withdrawals)
            return
        }
        
        if let error = (deposits as? Error) ?? (withdrawals as? Error) {
            resultBlock(true, nil, error)
            return
        }
        
        resultBlock(false, nil, nil)
    }
    
}

private extension ExchangeTransactionOperation {
    
    func taskFinished() {
        operatorIsExecuting = false
        operatorHasFinished = true
    }
    
    func fetchDeposits() {
        guard let depositRequest = requestBuilder.createRequest(with: action, for: .deposit) else {
            dataSyncer.deposits = []
            return
        }
        
        let task = session.dataTask(with: depositRequest) { (data, response, error) in
            let response = self.responseHandler.handleResponseData(for: self.action,
                                                                   data: data,
                                                                   error: error,
                                                                   urlResponse: response)
            self.dataSyncer.deposits = response
        }
        
        task.resume()
    }
    
    func fetchWithdrawals() {
        let withdrawalAction = requestBuilder.createTransactionAction(from: action)
        guard let withdrawalRequest = requestBuilder.createRequest(with: withdrawalAction, for: .withdrawal) else {
            dataSyncer.withdraws = []
            return
        }
        
        let task = session.dataTask(with: withdrawalRequest) { (data, response, error) in
            let response = self.responseHandler.handleResponseData(for: self.action,
                                                                   data: data,
                                                                   error: error,
                                                                   urlResponse: response)
            self.dataSyncer.withdraws = response
        }
        
        task.resume()
    }
    
}
