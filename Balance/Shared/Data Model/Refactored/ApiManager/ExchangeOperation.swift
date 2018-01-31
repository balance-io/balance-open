//
//  ExchangeOperation.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeOperation: Operation, OperationResult {
    
    var responseData: ExchangeOperationCompletionHandler?
    var handler: RequestHandler
    var session: URLSession
    var request: URLRequest
    var action: APIAction
    
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
    
    init(with handler: RequestHandler, action: APIAction, session: URLSession, request: URLRequest) {
        self.handler = handler
        self.action = action
        self.session = session
        self.request = request
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
            
            let response = self.handler.handleResponseData(for: self.action,
                                                           data: data,
                                                           error: error,
                                                           ulrResponse: response)
            
            self.completionBlock?()
            
            switch response {
            case is [ExchangeAccount], is [ExchangeTransaction]:
                self.responseData?(true, nil, response)
            case (let error) as Error:
                self.responseData?(false, error, nil)
            default:
                self.responseData?(false, nil, nil)
            }
            
        }
        
        task.resume()
    }
    
}
