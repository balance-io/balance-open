//
//  Defaults.swift
//  Bal
//
//  Created by Richard Burton on 5/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class Defaults {
    internal struct Keys {
        static let crashOnExceptions                    = "NSApplicationCrashOnExceptions"
        static let launchAtLogin                        = "launchAtLogin"
        static let accountIdsExcludedFromTotal          = "excludedFromAccountBalanceTotal"
        static let firstLaunch                          = "firstLaunch"
        static let accountsViewInstitutionsOrder        = "accountsViewInstitutionsOrder"
        static let accountsViewAccountsOrder            = "accountsViewAccountsOrder"
        static let hideAddAccountPrompt                 = "hideAddAccountPrompt"
        static let hideDefaultRulesPrompt               = "hideDefaultRulesPrompt"
        static let selectedThemeType                    = "selectedThemeType"
        static let promptedForLaunchAtLogin             = "promptedForLaunchAtLogin"
        static let lockSleep                            = "lockSleep"
        static let lockScreenSaver                      = "lockScreenSaver"
        static let lockClose                            = "lockClose"
        static let logCount                             = "logCount"
        static let serverMessageReadIds                 = "serverMessageReadIds"
    }
    
    // First run defaults
    func setupDefaults() {
        let dict: [String: Any] = [Keys.crashOnExceptions: true,
                                   Keys.launchAtLogin:     false,
                                   Keys.firstLaunch:       true,
                                   Keys.selectedThemeType: ThemeType.auto.rawValue]
        defaults.register(defaults: dict)
    }

    let defaults: DefaultsStorage
    
    required init(defaults: DefaultsStorage = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    var launchAtLogin: Bool {
        get {
            return defaults.bool(forKey: Keys.launchAtLogin)
        }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
        }
    }
    
    var firstLaunch: Bool {
        get {
            return defaults.bool(forKey: Keys.firstLaunch)
        }
        set {
            defaults.set(newValue, forKey: Keys.firstLaunch)
        }
    }
    
    var darkMode: Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
    
    var accountsViewInstitutionsOrder: [Int]? {
        get {
            if let institutionIds = defaults.array(forKey: Keys.accountsViewInstitutionsOrder) as? [Int] {
                return institutionIds
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.accountsViewInstitutionsOrder)
            } else {
                defaults.set(nil, forKey: Keys.accountsViewInstitutionsOrder)
            }
        }
    }
    
    var accountsViewAccountsOrder: [Int: [Int]]? {
        get {
            do {
                var dictionary: [Int: [Int]]?
                if let data = defaults.data(forKey: Keys.accountsViewAccountsOrder) {
                    try ObjC.catchException {
                        dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Int: [Int]]
                    }
                }
                return dictionary
            } catch {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
                defaults.set(data, forKey: Keys.accountsViewAccountsOrder)
            } else {
                defaults.set(nil, forKey: Keys.accountsViewAccountsOrder)
            }
        }
    }
    
    var logCount: Int {
        get {
            return defaults.integer(forKey: Keys.logCount)
        }
        set {
            defaults.set(newValue, forKey: Keys.logCount)
        }
    }
    
    var serverMessageReadIds: [Int] {
        get {
            return defaults.object(forKey: Keys.serverMessageReadIds) as? [Int] ?? [Int]()
        }
        set {
            defaults.set(newValue, forKey: Keys.serverMessageReadIds)
        }
    }

    // General Preferences
    
    var selectedThemeType: ThemeType {
        get {
            let rawValue = defaults.integer(forKey: Keys.selectedThemeType)
            if let themeType = ThemeType(rawValue: rawValue) {
                return themeType
            } else {
                return .auto
            }
        }
        set {
            let rawValue = newValue.rawValue
            defaults.set(rawValue, forKey: Keys.selectedThemeType)
        }
    }
    
    var promptedForLaunchAtLogin: Bool {
        get {
            return defaults.bool(forKey: Keys.promptedForLaunchAtLogin)
        }
        set {
            defaults.set(newValue, forKey: Keys.promptedForLaunchAtLogin)
        }
    }
}
