//
//  NotificationCenter.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

private func runInMainThread(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

extension NotificationCenter {
    
    //
    // MARK: - Main Thread -
    //
    
    static func postOnMainThread(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        runInMainThread {
            `default`.post(name: name, object: object, userInfo: userInfo)
        }
    }
    
    static func addObserverOnMainThread(_ observer: AnyObject, selector: Selector, name: Notification.Name, object: AnyObject? = nil) {
        runInMainThread {
            `default`.addObserver(observer, selector: selector, name: name, object: object)
        }
    }
    
    static func removeObserverOnMainThread(_ observer: AnyObject) {
        runInMainThread {
            `default`.removeObserver(observer)
        }
    }
    
    static func removeObserverOnMainThread(_ observer: AnyObject, name: Notification.Name, object: AnyObject? = nil) {
        runInMainThread {
            `default`.removeObserver(observer, name: name, object: object)
        }
    }
}
