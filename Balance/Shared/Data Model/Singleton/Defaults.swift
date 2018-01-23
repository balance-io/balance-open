//
//  Defaults.swift
//  Bal
//
//  Created by Richard Burton on 5/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
#if os(OSX)
    import ServiceManagement
#endif

//TODO - Research search URIs for native email Mac apps. Do they all have them?
enum EmailPreference: Int {
    case gmail          = 0
    case googleInbox    = 1
    //        case outlook        = 2
    //        case hotmail        = 3
    //        case mailApp        = 4
    //        case sparkApp       = 5
    //        case airmailApp     = 6
    //        case polyMailApp    = 7
}

enum SearchPreference: Int {
    case google         = 0
    case duckDuckGo     = 1
    case bing           = 2
}

class Defaults {
    internal struct Keys {
        static let crashOnExceptions                    = "NSApplicationCrashOnExceptions"
        static let uniqueKeychainString                 = "uniqueKeychainString"
        static let launchAtLogin                        = "launchAtLogin"
        static let accountIdsExcludedFromTotal          = "excludedFromAccountBalanceTotal"
        static let firstLaunch                          = "firstLaunch"
        static let accountsViewInstitutionsOrder        = "accountsViewInstitutionsOrder"
        static let accountsViewAccountsOrder            = "accountsViewAccountsOrder"
        static let hideAddAccountPrompt                 = "hideAddAccountPrompt"
        static let hideDefaultRulesPrompt               = "hideDefaultRulesPrompt"
        static let promptedForLaunchAtLogin             = "promptedForLaunchAtLogin"
        static let emailPreference                      = "emailPreference"
        static let searchPreference                     = "searchPreference"
        static let lockSleep                            = "lockSleep"
        static let lockScreenSaver                      = "lockScreenSaver"
        static let lockClose                            = "lockClose"
        static let unreadNotificationIds                = "unreadNotificationIds"
        static let institutionColors                    = "institutionColors"
        static let serverMessageReadIds                 = "serverMessageReadIds"
        static let logCount                             = "logCount"
        static let hiddenAccountIds                     = "hiddenAccountIds"
        static let unfinishedConnectionInstitutionIds   = "unfinishedConnectionInstitutionIds"
        static let masterCurrency                       = "masterCurrency"
        static let selectedCards                        = "selectedCardIndexes"
    }
    
    // First run defaults
    func setupDefaults() {
        let dict: [String: Any] = [Keys.crashOnExceptions:            true,
                                   Keys.launchAtLogin:                false,
                                   Keys.accountIdsExcludedFromTotal:  NSArray(),
                                   Keys.firstLaunch:                  true]
        defaults.register(defaults: dict)
        
        // Setup unread notification ids cache
        Defaults.unreadNotificationIdsCache = unreadNotificationIds
        
        // Generate a unique keychain string if needed
        generateUniqueKeychainString()
    }
    
    // Creates a keychain identifier for this installation only, changes on reinstall.
    // This allows us to reset the keychain for each install. Only used on iOS because
    // macOS users can delete keychain items using Keychain Access and are more likely
    // to accidentally clear their preferences causing data loss.
    func generateUniqueKeychainString() {
        #if DEBUG && os(iOS)
            if firstLaunch {
                uniqueKeychainString = String.random(16)
            }
        #endif
    }

    let defaults: DefaultsStorage
    
    required init(defaults: DefaultsStorage = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    var uniqueKeychainString: String {
        get {
            return defaults.string(forKey: Keys.uniqueKeychainString) ?? ""
        }
        set {
            defaults.set(newValue, forKey: Keys.uniqueKeychainString)
        }
    }
    
    #if os(OSX)
    var launchAtLogin: Bool {
        get {
            return defaults.bool(forKey: Keys.launchAtLogin)
        }
        set {
            if SMLoginItemSetEnabled(autolaunchBundleId as CFString, newValue) {
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
    #endif
    
    var accountIdsExcludedFromTotal: Set<Int> {
        if let accountIds = defaults.array(forKey: Keys.accountIdsExcludedFromTotal) as? [Int] {
            return Set(accountIds)
        } else {
            return Set<Int>()
        }
    }
    
    func excludeAccountIdFromTotal(_ accountId: Int) {
        var accountIds = accountIdsExcludedFromTotal
        accountIds.insert(accountId)
        defaults.set(Array(accountIds), forKey: Keys.accountIdsExcludedFromTotal)
        NotificationCenter.postOnMainThread(name: Notifications.AccountExcludedFromTotal)
    }
    
    func includeAccountIdInTotal(_ accountId: Int) {
        var accountIds = accountIdsExcludedFromTotal
        accountIds.remove(accountId)
        defaults.set(Array(accountIds), forKey: Keys.accountIdsExcludedFromTotal)
        NotificationCenter.postOnMainThread(name: Notifications.AccountIncludedInTotal)
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
    
    var hideAddAccountPrompt: Bool {
        get {
            return defaults.bool(forKey: Keys.hideAddAccountPrompt)
        }
        set {
            defaults.set(newValue, forKey: Keys.hideAddAccountPrompt)
        }
    }
    
    var hideDefaultRulesPrompt: Bool {
        get {
            return defaults.bool(forKey: Keys.hideDefaultRulesPrompt)
        }
        set {
            defaults.set(newValue, forKey: Keys.hideDefaultRulesPrompt)
        }
    }
    
    // Key is sourceInstitutionId, value is color index (0-19)
    var institutionColors: [String: Int] {
        get {
            return defaults.object(forKey: Keys.institutionColors) as? [String: Int] ?? [String: Int]()
        }
        set {
            defaults.set(newValue, forKey: Keys.institutionColors)
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
    
    var logCount: Int {
        get {
            return defaults.integer(forKey: Keys.logCount)
        }
        set {
            defaults.set(newValue, forKey: Keys.logCount)
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
    
    //General Preferences
    
    var promptedForLaunchAtLogin: Bool {
        get {
            return defaults.bool(forKey: Keys.promptedForLaunchAtLogin)
        }
        set {
            defaults.set(newValue, forKey: Keys.promptedForLaunchAtLogin)
        }
    }
    
    var emailPreferenceModified: Bool {
        return defaults.object(forKey: Keys.emailPreference) != nil
    }
    
    var emailPreference: EmailPreference {
        get {
            if let raw = defaults.object(forKey: Keys.emailPreference) as? Int, let emailPreference = EmailPreference(rawValue: raw) {
                return emailPreference
            }
            return .gmail
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.emailPreference)
        }
    }
    
    var searchPreference: SearchPreference {
        get {
            if let raw = defaults.object(forKey: Keys.searchPreference) as? Int, let searchPreference = SearchPreference(rawValue: raw) {
                return searchPreference
            }
            return .google
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.searchPreference)
        }
    }
    
    var isMasterCurrencySet: Bool {
        return defaults.object(forKey: Keys.masterCurrency) != nil
    }
    
    var masterCurrency: Currency! {
        get {
            if let raw = defaults.object(forKey: Keys.masterCurrency) as? String {
                return Currency.rawValue(raw)
            }
            
            // Default to current local if nothing is set
            if let currencyCode = NSLocale.current.currencyCode {
                return Currency.rawValue(currencyCode)
            }
            
            return .usd
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue.code, forKey: Keys.masterCurrency)
            } else {
                defaults.removeObject(forKey: Keys.masterCurrency)
            }
            
            NotificationCenter.postOnMainThread(name: Notifications.MasterCurrencyChanged)
        }
    }
    
    var selectedCards: [Int]? {
        get {
            return defaults.array(forKey: Keys.selectedCards) as? [Int]
        }
        
        set {
            guard let newValue = newValue,
                !newValue.isEmpty else {
                    defaults.removeObject(forKey: Keys.selectedCards)
                    return
            }
            
            defaults.set(newValue, forKey: Keys.selectedCards)
        }
    }
    
    // MARK: Notifications
    
    fileprivate static var unreadNotificationIdsCache = Set<Int>()
    var unreadNotificationIds: Set<Int> {
        get {
            return Defaults.unreadNotificationIdsCache
        }
        set {
            Defaults.unreadNotificationIdsCache = newValue
            defaults.set(Array(newValue), forKey: Keys.unreadNotificationIds)
        }
    }
    
    //
    // MARK: UI Testing
    //
    
    func setAccountIdsExcludedFromTotal(_ accountIds: [Int]) {
        defaults.set(accountIds, forKey: Keys.accountIdsExcludedFromTotal)
    }
}

extension Account {
    var isHidden: Bool {
        get {
            return defaults.hiddenAccountIds.contains(accountId)
        }
        set {
            if newValue {
                defaults.hideAccountId(accountId)
            } else {
                defaults.unhideAccountId(accountId)
            }
        }
    }
}
