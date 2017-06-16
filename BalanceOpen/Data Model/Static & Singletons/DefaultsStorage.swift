//
//  DefaultsStorage.swift
//  Bal
//
//  Created by Benjamin Baron on 9/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol DefaultsStorage {
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    func array(forKey defaultName: String) -> [Any]?
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func data(forKey defaultName: String) -> Data?
    func integer(forKey defaultName: String) -> Int
    func bool(forKey defaultName: String) -> Bool
    
    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)
    
    func removeObject(forKey defaultName: String)
    
    func register(defaults registrationDictionary: [String : Any])
}

extension UserDefaults: DefaultsStorage {
}
