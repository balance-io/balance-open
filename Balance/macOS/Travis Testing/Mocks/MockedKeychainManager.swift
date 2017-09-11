//
//  File.swift
//  Bal
//
//  Created by Jamie Rumbelow on 31/08/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class MockedKeychainManagerFactory: KeychainManagerFactory {
    override func instanceForAccount(_ account: String) -> KeychainManagement {
        var manager = MockedKeychainManagerFactory.instances[account]
        if manager == nil {
            manager = MockedKeychainManager(keychainName: account)
            MockedKeychainManagerFactory.instances[account] = manager
        }
        return manager!
    }
}

class MockedKeychainManager: KeychainManagement {
    fileprivate var data = [String: String]()
    
    let keychainName: String
    
    var empty: Bool {
        return data.count > 0
    }
    
    required init(keychainName: String) {
        self.keychainName = keychainName
        
        if keychainName == KeychainAccounts.Database {
            data = [KeychainKeys.Password: "bwFAv8jiJxktfFo5ygdERrt4LGmXclCO"]
        }
    }
    
    subscript (key: String) -> String? {
        get {
            return data[key]
        }
        set {
            data[key] = newValue
        }
    }
    
    func clear() {
        data = [:]
    }
}
