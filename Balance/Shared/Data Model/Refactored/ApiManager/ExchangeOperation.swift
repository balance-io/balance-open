//
//  ExchangeOperation.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeOperation: Operation, OperationResult {
    
    var responseData: ExchangeApiOperationCompletionHandler?
    var handler: OperationRequest
    
    
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
    
    init(with handler: OperationRequest) {
        self.handler = handler
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
    }
    
    override func main() {
        if isCancelled {
            taskFinished()
            return
        }
        
        guard let session = handler.sesion,
            let request = handler.request else {
                return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
        
        task.resume()
    }
    
}
