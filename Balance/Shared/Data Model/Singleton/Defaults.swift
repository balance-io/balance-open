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
import RealmSwift

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
        static let launchAtLogin                        = "launchAtLogin"
        static let accountIdsExcludedFromTotal          = "excludedFromAccountBalanceTotal"
        static let firstLaunch                          = "firstLaunch"
        static let accountsViewInstitutionsOrder        = "accountsViewInstitutionsOrder"
        static let accountsViewAccountsOrder            = "accountsViewAccountsOrder"
        static let hideAddAccountPrompt                 = "hideAddAccountPrompt"
        static let hideDefaultRulesPrompt               = "hideDefaultRulesPrompt"
        static let selectedThemeType                    = "selectedThemeType"
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
        static let feedRules                            = "feedRules"
    }
    
    // First run defaults
    func setupDefaults() {
        let dict: [String: Any] = [Keys.crashOnExceptions:                  true,
                                         Keys.launchAtLogin:                false,
                                         Keys.accountIdsExcludedFromTotal:  NSArray(),
                                         Keys.firstLaunch:                  true,
                                         Keys.selectedThemeType:            ThemeType.auto.rawValue]
        defaults.register(defaults: dict)
        
        // Setup unread notification ids cache
        Defaults.unreadNotificationIdsCache = unreadNotificationIds
    }

    let defaults: DefaultsStorage
    
    required init(defaults: DefaultsStorage = UserDefaults.standard) {
        self.defaults = defaults
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

// Deprecated
extension Defaults {
    var feedRules: [FeedRule]? {
        get {
            do {
                var feedRules: [FeedRule]?
                if let feedRulesData = defaults.data(forKey: Keys.feedRules) {
                    try ObjC.catchException {
                        feedRules = NSKeyedUnarchiver.unarchiveObject(with: feedRulesData) as? [FeedRule]
                    }
                }
                return feedRules
            } catch {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let feedRulesData = NSKeyedArchiver.archivedData(withRootObject: newValue)
                defaults.set(feedRulesData, forKey: Keys.feedRules)
            } else {
                defaults.set(nil, forKey: Keys.feedRules)
            }
        }
    }
}

// Depricated
class FeedRule: NSObject, NSCoding {
    
    var ruleId: Int
    var name: String
    var notify: Bool
    
    // Dictionary of search tags representing this rule, i.e. [.Name: "Uber", .More: "50"]
    var searchTokens: [SearchToken: String]
    
    var displayName: String {
        if name.length > 0 {
            return name
        }
        
        let orderedTokens: [SearchToken] = [.over, .under, .amount, .accountMatches, .name, .nameMatches, .nameNot, .nameMatchesNot, .categoryMatches]
        
        var displayNameParts = [String]()
        for token in orderedTokens {
            if let value = searchTokens[token] {
                switch token {
                case .over:
                    if let cents = stringToCents(value) {
                        let amount = centsToString(cents)
                        displayNameParts.append("over \(amount)")
                    }
                case .under:
                    if let cents = stringToCents(value) {
                        let amount = centsToString(cents)
                        displayNameParts.append("under \(amount)")
                    }
                case .amount:
                    if let cents = stringToCents(value) {
                        let amount = centsToString(cents)
                        displayNameParts.append("exactly \(amount)")
                    }
                case .accountMatches:
                    displayNameParts.append("in \(value)")
                case .name:
                    displayNameParts.append("containing \"\(value)\"")
                case .nameMatches:
                    displayNameParts.append("matching \"\(value)\"")
                case .nameNot:
                    displayNameParts.append("not containing \"\(value)\"")
                case .nameMatchesNot:
                    displayNameParts.append("not matching \"\(value)\"")
                case .categoryMatches:
                    displayNameParts.append("in category \"\(value)\"")
                default:
                    break
                }
            }
        }
        
        if displayNameParts.count == 0 {
            return "New Rule"
        } else {
            return (displayNameParts as NSArray).componentsJoined(by: ", ").capitalizedFirstLetterString
        }
    }
    
    init(ruleId: Int, name: String, notify: Bool, searchTokens: [SearchToken: String]) {
        self.ruleId = ruleId
        self.name = name
        self.notify = notify
        self.searchTokens = searchTokens
    }
    
    override var hashValue: Int {
        return ruleId.hashValue
    }
    
    // MARK: - NSCoding -
    
    fileprivate struct Keys {
        static let ruleId       = "ruleId"
        static let name         = "name"
        static let notify       = "notify"
        static let searchTokens = "searchTokens"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        ruleId = aDecoder.decodeInteger(forKey: Keys.ruleId)
        name = aDecoder.decodeObject(forKey: Keys.name) as? String ?? ""
        notify = aDecoder.decodeBool(forKey: Keys.notify)
        
        let searchTokensStrings = aDecoder.decodeObject(forKey: Keys.searchTokens) as? [String: String] ?? [String: String]()
        var searchTokensEnums = [SearchToken: String]()
        for item in searchTokensStrings {
            if let token = SearchToken(rawValue: item.0) {
                searchTokensEnums[token] = item.1
            }
        }
        searchTokens = searchTokensEnums
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(ruleId, forKey: Keys.ruleId)
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(notify, forKey: Keys.notify)
        
        var searchTokensStrings = [String: String]()
        for item in searchTokens {
            searchTokensStrings[item.0.rawValue] = item.1
        }
        aCoder.encode(searchTokensStrings, forKey: Keys.searchTokens)
    }
}
