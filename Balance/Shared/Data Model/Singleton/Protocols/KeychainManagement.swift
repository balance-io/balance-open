//
//  KeychainManagement.swift
//  Bal
//
//  Created by Jamie Rumbelow on 30/08/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KeychainAccounts {
    static let Database = "database"
    static let AppLock = "appLock"
    static let Subscription = "subscription"
}

struct KeychainKeys {
    static let Password = "password"
    static let PasswordHint = "passwordHint"
    static let LockEnabled = "lockEnabled"
    static let LockOnSleep = "lockOnSleep"
    static let LockOnScreenSaver = "lockOnScreenSaver"
    static let LockOnPopoverClose = "lockOnPopoverClose"
    static let KeychainEnabled = "keychainEnabled"
    static let TouchIdEnabled = "touchIdEnabled"
    static let InfoDictionary = "infoDictionary"
}

protocol KeychainManagement {
    var keychainName: String { get }
    var empty: Bool { get }
    
    init(keychainName: String)
    
    subscript (key: String) -> String? { get set }
    func clear()
}
