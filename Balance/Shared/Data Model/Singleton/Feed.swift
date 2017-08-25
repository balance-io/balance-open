//
//  Feed.swift
//  Bal
//
//  Created by Benjamin Baron on 8/2/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import RealmSwift
#if os(iOS)
import UserNotifications
#endif

typealias TemplateId = Int
struct TemplateIds {
    static let transactionName          = 0
    static let accountName              = 1
    static let categoryName             = 2
    static let transactionAmountUnder   = 3
    static let transactionAmountOver    = 4
}

typealias StringMatchingOption = String
struct StringMatchingOptions {
    static let contains = "contains"
    static let matches = "matches"
    static let doesNotContain = "doesNotContain"
    static let doesNotMatch = "doesNotMatch"
    
    static let allOptions = [contains, matches, doesNotContain, doesNotMatch]
}

typealias ComparisonOption = String
struct ComparisonOptions {
    static let lessThan = "is less than"
    static let moreThan = "is more than"
    static let equalTo  = "is equal to"
    
    static let allOptions = [lessThan, moreThan, equalTo]
}

class Feed {
    init() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(realmAuthenticated), name: Notifications.RealmAuthenticated)
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.RealmAuthenticated)
        rulesNotificationToken?.stop()
    }
    
    fileprivate var prefsRealm: Realm?
    fileprivate var rulesNotificationToken: NotificationToken?
    @objc fileprivate func realmAuthenticated() { 
        if rulesNotificationToken == nil, let realm = realmManager.prefsRealm {
            // Keep a reference to the realm so that we keep getting notifications
            prefsRealm = realm
            rulesNotificationToken = realm.objects(Rule.self).addNotificationBlock { [weak self] changes in
                switch changes {
                case .update(_, _, let insertions, _):
                    // Generic notification in case we need it
                    NotificationCenter.postOnMainThread(name: Notifications.RulesChanged)
                    
                    // Dedupe newly added rules
                    if insertions.count > 0 {
                        async { self?.dedupeRules() }
                    }
                default:
                    // TODO: Probably handle the other cases
                    break
                }
            }
        }
        
        convertOldFeedRules()
    }
    
    // In case a user creates the same rule on two machines while offline, we should only keep one.
    // Also to prevent dupes from converting old to new rule objects
    func dedupeRules() {
        var dupes = [Rule]()
        let allRules = rules
        for rule in allRules {
            for possibleDupe in allRules {
                // Look for rules with the same contents
                if rule.ruleId != possibleDupe.ruleId && rule.generatedName == possibleDupe.generatedName {
                    // Check if we already caught one of the dupes
                    if !dupes.contains(rule) && !dupes.contains(possibleDupe) {
                        // Remove the newest one
                        if rule.created > possibleDupe.created {
                            dupes.append(rule)
                        } else {
                            dupes.append(possibleDupe)
                        }
                    }
                }
            }
        }
        
        for dupe in dupes {
            deleteRule(dupe)
        }
    }
    
    // Convert old NSUserDefaults based FeedRule objects to the new Realm based Rule objects
    fileprivate func convertOldFeedRules() {
        if let feedRules = defaults.feedRules {
            for feedRule in feedRules {
                _ = createRule(name: feedRule.name, notify: feedRule.notify, searchTokens: feedRule.searchTokens)
                print("Converted feed rule")
            }
        }
        defaults.feedRules = nil
    }
    
    var rules: [Rule] {
        if let realm = realmManager.prefsRealm {
            let objects = realm.objects(Rule.self).sorted(byKeyPath: "created")
            return Array(objects)
        }
        
        return [Rule]()
    }
    
    var numberOfActiveRules: Int {
        var numberOfActiveRules = 0
        for rule in rules {
            if rule.searchTokens.count > 0 {
                numberOfActiveRules += 1
            }
        }
        return numberOfActiveRules
    }

    func ruleForId(_ ruleId: String) -> Rule? {
        if let realm = realmManager.prefsRealm {
            let objects = realm.objects(Rule.self).filter("ruleId = '\(ruleId)'")
            return objects.first
        }
        return nil
    }
    
    func createRule(name: String = "", notify: Bool = false, searchTokens: [SearchToken: String] = [SearchToken: String](), withoutNotifying tokens: [NotificationToken] = []) -> Rule {
        let rule = Rule(ruleId: UUID().uuidString, name: name, notify: notify, searchTokens: searchTokens)
        
        realmManager.writePrefs(withoutNotifying: tokens) { realm in
            realm.add(rule)
        }
        
        return rule
    }
    
    func deleteRule(_ rule: Rule, withoutNotifying tokens: [NotificationToken] = []) {
        realmManager.writePrefs(withoutNotifying: tokens) { realm in
            realm.delete(rule)
        }
    }
    
    fileprivate func haveNewAccounts() -> Bool {
        let institutions = InstitutionRepository.si.allInstitutions()
        for institution in institutions {
            if institution.isNewInstitution {
                return true
            }
        }
        return false
    }
    
    fileprivate func filterOutNewAccounts(transactions: [Transaction]) -> [Transaction] {
        if haveNewAccounts() {
            // Remove transactions from new accounts, so only accounts older than 1 day cause notifications
            let filtered = transactions.filter { transaction in
                if let institution = transaction.account?.institution {
                    return !institution.isNewInstitution
                }
                return false
            }
            return filtered
        }
        
        return transactions
    }

    func transactionIdsMatchingRule(_ rule: Rule, sinceTransactionId: Int = 0, includingNewAccounts: Bool = true) -> Set<Int> {
        var transactionIds = Search.transactionIdsMatchingTokens(rule.searchTokens)
        if sinceTransactionId > 0 {
            let filtered = transactionIds.filter({$0 > sinceTransactionId})
            transactionIds = Set<Int>(filtered)
        }
        
        if !includingNewAccounts && haveNewAccounts() {
            var transactions = [Transaction]()
            for transactionId in transactionIds {
                if let transaction = TransactionRepository.si.transaction(transactionId: transactionId) {
                    transactions.append(transaction)
                }
            }
            
            let filtered = filterOutNewAccounts(transactions: transactions).map({$0.transactionId})
            return Set<Int>(filtered)
        }
        
        return transactionIds
    }
    
    func transactionsMatchingRule(_ rule: Rule, sinceTransactionId: Int = 0, includingNewAccounts: Bool = true) -> [Transaction] {
        var transactions = [Transaction]()
        
        let transactionIds = transactionIdsMatchingRule(rule, sinceTransactionId: sinceTransactionId)
        let sortedIds: [Int] = Array(transactionIds).sorted().reversed()
        for transactionId in sortedIds {
            if let transaction = TransactionRepository.si.transaction(transactionId: transactionId) {
                transactions.append(transaction)
            }
        }
        
        return includingNewAccounts ? transactions : filterOutNewAccounts(transactions: transactions)
    }
    
    func allMatchingTransactionIdsByRule(sinceTransactionId: Int = 0) -> [Rule: Set<Int>] {
        var transactionIdsByRule = [Rule: Set<Int>]()
        
        // Get the transaction ids
        for rule in rules {
            let matchingIds = transactionIdsMatchingRule(rule, sinceTransactionId: sinceTransactionId)
            transactionIdsByRule[rule] = matchingIds
        }
        
        return transactionIdsByRule
    }
    
    func allMatchingTransactions(includingNewAccounts: Bool = true) -> [Transaction] {
        var transactions = [Transaction]()
        
        // Get the transaction ids
        let transactionIdsByRule = allMatchingTransactionIdsByRule()
        var transactionIds = Set<Int>()
        for ids in transactionIdsByRule.values {
            transactionIds.formUnion(ids)
        }
    
        // Get the transactions
        for transactionId in transactionIds {
            if let transaction = TransactionRepository.si.transaction(transactionId: transactionId) {
                var ruleNames = [String]()
                for rule in rules {
                    if let ids = transactionIdsByRule[rule] {
                        if ids.contains(transactionId) {
                            ruleNames.append(rule.displayName)
                        }
                    }
                }
                transaction.ruleNames = ruleNames
                transactions.append(transaction)
            }
        }
        
        // Sort them by reverse chronological
        let sortedTransactions = transactions.sorted {
            $0.date.compare($1.date as Date) == .orderedDescending
        }
        
        return includingNewAccounts ? sortedTransactions : filterOutNewAccounts(transactions: sortedTransactions)
    }
    
    func transactionsbyDate(transactions: [Transaction]) -> OrderedDictionary<Date, [Transaction]> {
        var transactionsByDate = OrderedDictionary<Date, [Transaction]>()
        
        var firstRow = true
        var previousDate = Date.distantFuture
        let calendar = Calendar.current
        var tempTransactions = [Transaction]()
        
        for transaction in transactions {
            // Setup the dictionary key if first row
            if firstRow {
                previousDate = transaction.date as Date
                firstRow = false
            }
            
            // If not pending and dates don't match, store the previous transactions in the dictionary
            if !calendar.isDate(previousDate, inSameDayAs: transaction.date as Date) {
                transactionsByDate[previousDate] = tempTransactions
                tempTransactions = [Transaction]()
                previousDate = transaction.date as Date
            }
            
            // Append this transaction
            tempTransactions.append(transaction)
        }
        
        // Insert the late date section
        if tempTransactions.count > 0 {
            transactionsByDate[previousDate] = tempTransactions
        }
        
        return transactionsByDate
    }
    
    func allNotifyTransactions(sinceTransactionId: Int = 0) -> [Transaction] {
        let notifyRules = rules.filter({$0.notify})
        var transactionIds = Set<Int>()
        for rule in notifyRules {
            transactionIds.formUnion(transactionIdsMatchingRule(rule, sinceTransactionId: sinceTransactionId))
        }
        
        var transactions = [Transaction]()
        let sortedIds: [Int] = Array(transactionIds).sorted().reversed()
        for transactionId in sortedIds {
            if let transaction = TransactionRepository.si.transaction(transactionId: transactionId) {
                transactions.append(transaction)
            }
        }
        
        return filterOutNewAccounts(transactions: transactions)
    }
    
    func unreadTransactionIds(sinceTransactionId: Int = 0) -> Set<Int> {
        var transactionIds = Set<Int>()
        for rule in rules {
            transactionIds.formUnion(transactionIdsMatchingRule(rule, sinceTransactionId: sinceTransactionId, includingNewAccounts: false))
        }
        return transactionIds
    }
    
    func sendTransactionNotifications(transactions: [Transaction]) {
        for transaction in transactions {
            let title = transaction.rulesDisplayName ?? "Matching transaction"
            let body = "\(centsToStringFormatted(-transaction.amount).string) \(transaction.displayName)"
            
            #if os(OSX)
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = body
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
            #else
            // TODO: Fill this in for iOS
            #endif
        }
    }
    
    func defaultRuleTemplates() -> [TemplateId: RuleTemplate] {
        let accountNames = AccountRepository.si.allAccounts().map{$0.displayName}
        let categoryNames = CategoryRepository.si.allCategoryNames()
        
        let transactionName = [Element(type: .label, defaultValue: ["Name of the transaction"]),
                               Element(type: .comboBox, defaultValue: StringMatchingOptions.allOptions, label: "String Matching Options"),
                               Element(type: .textField, defaultValue: [""], width: 80)]
        let transactionNameTemplate = RuleTemplate(templateId: TemplateIds.transactionName, name: "transaction name", elements: transactionName)
        
        let accountName = [Element(type: .label, defaultValue: ["Transaction is in"]),
                           Element(type: .comboBox, defaultValue: accountNames, label: "Account Names")]
        let accountNameTemplate = RuleTemplate(templateId: TemplateIds.accountName, name: "account name", elements: accountName)
        
        let categoryName = [Element(type: .label, defaultValue: ["Transaction is in the category"]),
                            Element(type: .comboBox, defaultValue: categoryNames, label: "Category Names")]
        let categoryNameTemplate = RuleTemplate(templateId: TemplateIds.categoryName, name: "category name", elements: categoryName)
        
        let transactionAmountUnder = [Element(type: .label, defaultValue: ["Transaction amount is under"]),
                                      Element(type: .numberField, defaultValue: [""], width: 100, label: "Rule Amount")]
        let transactionAmountUnderTemplate = RuleTemplate(templateId: TemplateIds.transactionAmountUnder, name: "transaction amount under", elements: transactionAmountUnder)
        
        let transactionAmountOver = [Element(type: .label, defaultValue: ["Transaction amount is over"]),
                                     Element(type: .numberField, defaultValue: [""], width: 100, label: "Rule Amount")]
        let transactionAmountOverTemplate = RuleTemplate(templateId: TemplateIds.transactionAmountOver, name: "transaction amount over", elements: transactionAmountOver)
        
        let ruleTemplates = [TemplateIds.transactionName:        transactionNameTemplate,
                             TemplateIds.accountName:            accountNameTemplate,
                             TemplateIds.categoryName:           categoryNameTemplate,
                             TemplateIds.transactionAmountUnder: transactionAmountUnderTemplate,
                             TemplateIds.transactionAmountOver:  transactionAmountOverTemplate]
        return ruleTemplates
    }
    
    func ruleTemplatesForSearchTokens(_ searchTokens: [SearchToken: String]) -> [RuleTemplate] {
        let defaultTemplates = defaultRuleTemplates()
        var ruleTemplates = [RuleTemplate]()
        
        for token in searchTokens {
            switch token.0 {
            case .accountMatches:
                if let template = defaultTemplates[TemplateIds.accountName] {
                    for i in 0...template.elements.count-1 {
                        let element = template.elements[i]
                        if element.type == .comboBox {
                            template.elements[i].stringValue = token.1
                            break
                        }
                    }
                    ruleTemplates.append(template)
                }
            case .categoryMatches:
                if let template = defaultTemplates[TemplateIds.categoryName] {
                    for i in 0...template.elements.count-1 {
                        if template.elements[i].type == .comboBox {
                            template.elements[i].stringValue = token.1
                            break
                        }
                    }
                    ruleTemplates.append(template)
                }
            case .name, .nameMatches, .nameNot, .nameMatchesNot:
                if let template = defaultTemplates[TemplateIds.transactionName] {
                    for i in 0...template.elements.count-1 {
                        if template.elements[i].type == .comboBox {
                            switch token.0 {
                            case .name:
                                template.elements[i].stringValue = StringMatchingOptions.contains
                            case .nameMatches:
                                template.elements[i].stringValue = StringMatchingOptions.matches
                            case .nameNot:
                                template.elements[i].stringValue = StringMatchingOptions.doesNotContain
                            case .nameMatchesNot:
                                template.elements[i].stringValue = StringMatchingOptions.doesNotMatch
                            default: break
                            }
                        } else if template.elements[i].type == .textField {
                            template.elements[i].stringValue = token.1
                        }
                    }
                    ruleTemplates.append(template)
                }
            case .under:
                if let template = defaultTemplates[TemplateIds.transactionAmountUnder] {
                    for i in 0...template.elements.count-1 {
                        if template.elements[i].type == .numberField {
                            template.elements[i].stringValue = token.1
                        }
                    }
                    ruleTemplates.append(template)
                }
            case .over:
                if let template = defaultTemplates[TemplateIds.transactionAmountOver] {
                    for i in 0...template.elements.count-1 {
                        if template.elements[i].type == .numberField {
                            template.elements[i].stringValue = token.1
                        }
                    }
                    ruleTemplates.append(template)
                }
            default:
                break
            }
        }
        
        return ruleTemplates
    }
    
    func searchTokensForRuleTemplates(_ ruleTemplates: [RuleTemplate]) -> [SearchToken: String] {
        var searchTokens = [SearchToken: String]()
        for rule in ruleTemplates {
            switch rule.templateId {
            case TemplateIds.accountName:
                for element in rule.elements {
                    if element.type == .comboBox {
                        searchTokens[.accountMatches] = element.stringValue
                        break
                    }
                }
            case TemplateIds.transactionName:
                var searchToken: SearchToken?
                var value: String?
                for element in rule.elements {
                    if element.type == .comboBox, let stringValue = element.stringValue {
                        switch stringValue {
                        case StringMatchingOptions.contains:        searchToken = .name
                        case StringMatchingOptions.matches:         searchToken = .nameMatches
                        case StringMatchingOptions.doesNotContain:  searchToken = .nameNot
                        case StringMatchingOptions.doesNotMatch:    searchToken = .nameMatchesNot
                        default: break
                        }
                    } else if element.type == .textField, let stringValue = element.stringValue {
                        value = stringValue
                    }
                }
                
                if let searchToken = searchToken, let value = value {
                    searchTokens[searchToken] = value
                }
            case TemplateIds.categoryName:
                for element in rule.elements {
                    if element.type == .comboBox {
                        searchTokens[.categoryMatches] = element.stringValue
                        break
                    }
                }
            case TemplateIds.transactionAmountUnder:
                for element in rule.elements {
                    if element.type == .numberField, let stringValue = element.stringValue {
                        searchTokens[.under] = stringValue
                    }
                }
            case TemplateIds.transactionAmountOver:
                for element in rule.elements {
                    if element.type == .numberField, let stringValue = element.stringValue {
                        searchTokens[.over] = stringValue
                    }
                }
            default:
                break
            }
        }
        
        return searchTokens
    }
    
    // MARK: - Default rules -
    
    let defaultRules = [Rule(ruleId: "", name: "", notify: false, searchTokens: [.over: "$100"]),
                        Rule(ruleId: "", name: "", notify: true, searchTokens: [.over: "$500"]),
                        Rule(ruleId: "", name: "", notify: true, searchTokens: [.categoryMatches: "Bank Fees"])]
    
    var remainingDefaultRules: [Rule] {
        return defaultRules.filter({!Feed.ruleMatches(dafaultRule: $0)})
    }
    
    // true if notify is equal and it contains the search token (value is disregarded)
    fileprivate static func ruleMatches(dafaultRule: Rule) -> Bool {
        for rule in feed.rules {
            let ruleTokens = Set(rule.searchTokens.keys)
            let defaultRuleTokens = Set(dafaultRule.searchTokens.keys)
            //print("ruleTokens: \(ruleTokens)")
            //print("defaultRuleTokens: \(defaultRuleTokens)")
            if rule.notify == dafaultRule.notify && ruleTokens.intersection(defaultRuleTokens).count > 0 {
                return true
            }
        }
        return false
    }
    
    // MARK: - Realm Notifictions -
    
    
}
