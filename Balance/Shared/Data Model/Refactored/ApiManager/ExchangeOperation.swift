//
//  ExchangeOperation.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

//TODO: Felipe - coinbase operation should be concurrent becuase there are many transactions and use a non concurrent approach will take much time, for other exchange we should use non concurrent becuase some of them use nonce param on the request and sometimes concurrent request can create invalid nonce(repeated, similar times like e.g 123456789112233445566 and 123456789112233445456).

class ExchangeOperation: Operation {
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
        }
    }
    
}
