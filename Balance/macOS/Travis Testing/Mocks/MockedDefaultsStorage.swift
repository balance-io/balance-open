//
//  MockedNSUserDefaults.swift
//  Bal
//
//  Created by Benjamin Baron on 9/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class MockedDefaultsStorage: DefaultsStorage {
    fileprivate var data = [String: Any]()
    
    func object(forKey defaultName: String) -> Any? {
        return data[defaultName]
    }
    
    func string(forKey defaultName: String) -> String? {
        return object(forKey: defaultName) as? String
    }
    
    func array(forKey defaultName: String) -> [Any]? {
        return object(forKey: defaultName) as? [Any]
    }
    
    func dictionary(forKey defaultName: String) -> [String : Any]? {
        return object(forKey: defaultName) as? [String: Any]
    }
    
    func data(forKey defaultName: String) -> Data? {
        return object(forKey: defaultName) as? Data
    }
    
    func integer(forKey defaultName: String) -> Int {
        return object(forKey: defaultName) as? Int ?? 0
    }
    
    func bool(forKey defaultName: String) -> Bool {
        return object(forKey: defaultName) as? Bool ?? false
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        data[defaultName] = value
    }
    
    func set(_ value: Int, forKey defaultName: String) {
        set(value, forKey: defaultName)
    }
    
    func set(_ value: Bool, forKey defaultName: String) {
        set(value, forKey: defaultName)
    }
    
    func removeObject(forKey defaultName: String) {
        data.removeValue(forKey: defaultName)
    }
    
    func register(defaults registrationDictionary: [String : Any]) {
        for item in registrationDictionary {
            if data[item.0] == nil {
                data[item.0] = item.1
            }
        }
    }
}
