//
//  ExchangeOperation.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeOperation: Operation, OperationResult {
    var handler: RequestHandler
    var action: APIAction?
    var session: URLSession
    var request: URLRequest
    var resultBlock: ExchangeOperationCompletionHandler
    
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
    
    override var isExecuting: Bool {
        return operatorIsExecuting
    }
    
    override var isFinished: Bool {
        return operatorHasFinished
    }
    
    override var isConcurrent: Bool {
        return false
    }
    
    init(with handler: RequestHandler, action: APIAction? = nil, session: URLSession? = nil, request: URLRequest, resultBlock: @escaping ExchangeOperationCompletionHandler) {
        self.handler = handler
        self.action = action
        self.session = session ?? certValidatedSession
        self.request = request
        self.resultBlock = resultBlock
    }
    
    func taskFinished() {
        operatorIsExecuting = false
        operatorHasFinished = true
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
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if self.isCancelled {
                self.taskFinished()
                return
            }
            
            let response = self.handler.handleResponseData(for: self.action, data: data, error: error, urlResponse: response)
            
            self.completionBlock?()
            
            switch response {
            case is [ExchangeAccount], is [ExchangeTransaction], is CoinbaseAutentication:
                self.resultBlock(true, nil, response)
            case (let error) as Error:
                self.resultBlock(false, error, nil)
            default:
                self.resultBlock(false, nil, nil)
            }
        }
        
        task.resume()
    }
}
