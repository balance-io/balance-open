//
//  ExchangeOperation.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

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
