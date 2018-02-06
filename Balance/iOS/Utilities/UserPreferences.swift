//
//  UserPreferences.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


final class UserPreferences
{
    // Fileprivate
    fileprivate let identifier: String
    fileprivate let userDefaults: UserDefaults
    
    // MARK: Initialization
    
    init(identifier: String, userDefaults: UserDefaults)
    {
        self.identifier = identifier
        self.userDefaults = userDefaults
    }
    
    // MARK: Key builder
    
    fileprivate func preferenceKey(for key: String) -> String
    {
        return "com.balanceios.UserPreferences.\(self.identifier).\(key)"
    }
}


// MARK: Theme

extension UserPreferences
{
    enum Theme: String
    {
        static let available: [Theme] = [.automatic, .night, .light]
        
        case automatic, night, light
        
        // MARK: Title
        
        func title() -> String
        {
            return self.rawValue.capitalized
        }
    }
    
    var theme: Theme {
        set(newValue)
        {
            let key = self.preferenceKey(for: "theme")
            self.userDefaults.set(newValue.rawValue, forKey: key)
        }
        
        get
        {
            let key = self.preferenceKey(for: "theme")
            guard let rawValue = self.userDefaults.string(forKey: key),
                  let theme = Theme(rawValue: rawValue) else
            {
                return .automatic
            }
            
            return theme
        }
    }
}
