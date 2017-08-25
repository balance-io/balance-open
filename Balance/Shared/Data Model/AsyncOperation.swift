////
////  AsyncOperation.swift
////  Bal
////
////  Created by Benjamin Baron on 2/16/17.
////  Copyright © 2017 Balanced Software, Inc. All rights reserved.
////
//
//import Foundation
//
//class AsyncOperation: Operation {
//    override var isAsynchronous: Bool {
//        return true
//    }
//    
//    override var isExecuting: Bool {
//        return isExecutingInternal
//    }
//    
//    override var isFinished: Bool {
//        return isFinishedInternal
//    }
//    
//    fileprivate var isExecutingInternal = false {
//        willSet {
//            willChangeValue(forKey: "isExecuting")
//        }
//        didSet {
//            didChangeValue(forKey: "isExecuting")
//        }
//    }
//    
//    fileprivate var isFinishedInternal = false {
//        willSet {
//            willChangeValue(forKey: "isFinished")
//        }
//        
//        didSet {
//            didChangeValue(forKey: "isFinished")
//        }
//    }
//    
//    override func start() {
//        isExecutingInternal = true
//        execute()
//    }
//    
//    func execute() {
//        var shouldLoad = true
//        if onlyLoadIfNotExists {
//            // Only load if it's not persisted
//            if let persistedItem = loader.associatedObject as? PersistedItem {
//                // If we have duplicate loaders in the queue, the first one should have a nil associated object
//                // and the second one should have isPersisted = true, so should skip loading.
//                shouldLoad = !persistedItem.isPersisted
//            }
//        }
//        
//        if shouldLoad {
//            loader.completionHandler = { _, _, _ in
//                self.finish()
//            }
//            loader.start()
//        } else {
//            finish()
//        }
//    }
//    
//    func finish() {
//        // Notify the completion of async task and hence the completion of the operation
//        isExecutingInternal = false
//        isFinishedInternal = true
//    }
//}
