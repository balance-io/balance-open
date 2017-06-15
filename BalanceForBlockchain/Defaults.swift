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
        static let selectedThemeType                    = "selectedThemeType"
        static let promptedForLaunchAtLogin             = "promptedForLaunchAtLogin"
        static let lockSleep                            = "lockSleep"
        static let lockScreenSaver                      = "lockScreenSaver"
        static let lockClose                            = "lockClose"
        static let logCount                             = "logCount"
        static let serverMessageReadIds                 = "serverMessageReadIds"
        static let hiddenAccountIds                     = "hiddenAccountIds"
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
            if autoLaunch.launchAtLogin(newValue) {
                defaults.set(newValue, forKey: Keys.launchAtLogin)
            } else {
                log.severe("Failed to set login at launch preference")
                
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = newValue ? "Unable to create the login item" : "Unable to remove the login item"
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
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
    
    var hiddenAccountIds: Set<Int> {
        if let accountIds = defaults.array(forKey: Keys.hiddenAccountIds) as? [Int] {
            return Set(accountIds)
        } else {
            return Set<Int>()
        }
    }
    
    var hiddenAccountIdsQuerySet: String {
        let accountIds = hiddenAccountIds
        var string = "("
        for (index, id) in accountIds.enumerated() {
            if index > 0 {
                string += ","
            }
            string += "\(id)"
        }
        string += ")"
        return string
    }
    
    func hideAccountId(_ accountId: Int) {
        var accountIds = hiddenAccountIds
        accountIds.insert(accountId)
        defaults.set(Array(accountIds), forKey: Keys.hiddenAccountIds)
        let userInfo = [Notifications.Keys.AccountId: accountId]
        NotificationCenter.postOnMainThread(name: Notifications.AccountHidden, userInfo: userInfo)
    }
    
    func unhideAccountId(_ accountId: Int) {
        var accountIds = hiddenAccountIds
        accountIds.remove(accountId)
        defaults.set(Array(accountIds), forKey: Keys.hiddenAccountIds)
        let userInfo = [Notifications.Keys.AccountId: accountId]
        NotificationCenter.postOnMainThread(name: Notifications.AccountUnhidden, userInfo: userInfo)
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
