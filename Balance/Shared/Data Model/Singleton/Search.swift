//
//  Search.swift
//  Bal
//
//  Created by Benjamin Baron on 5/14/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum SearchToken: String {
    case `in`                = "in"
    case inNot               = "-in"
    case account             = "account"
    case accountNot          = "-account"
    case accountMatches      = "account="
    case accountMatchesNot   = "-account="
    case category            = "category"
    case categoryNot         = "-category"
    case categoryMatches     = "category="
    case categoryMatchesNot  = "-category="
    case amount              = "amount"
    case amountNot           = "-amount"
    case over                = "over"
    case under               = "under"
    case when                = "when"
    case whenNot             = "-when"
    case before              = "before"
    case after               = "after"
    case name                = "name"
    case nameNot             = "-name"
    case nameMatches         = "name="
    case nameMatchesNot      = "-name="
    
    static var orderedTokens: [SearchToken] = [.in, .inNot, .account, .accountNot, .accountMatches, .accountMatchesNot,
                                               .category, .categoryNot, .categoryMatches, .categoryMatchesNot,
                                               .amount, .amountNot, .over, .under, .when, .whenNot, .before, .after,
                                               .nameNot, .nameMatches, .nameMatchesNot, .name]
    
    static var notTokens: [SearchToken] = [.inNot, .accountNot, .accountMatchesNot, .categoryNot, categoryMatchesNot,
                                           .nameNot, .nameMatchesNot, .amountNot, .whenNot]
    
    static var matchesTokens: [SearchToken] = [.accountMatches, .accountMatchesNot, .categoryMatches, .categoryMatchesNot,
                                               .nameMatches, .nameMatchesNot]
}

struct SearchTokenData: Equatable {
    let value: String
    let tokenRange: NSRange
    let valueRange: NSRange
    
    static func ==(lhs: SearchTokenData, rhs: SearchTokenData) -> Bool {
        return lhs.value == rhs.value
    }
}

class Search {
    static func tokenizeSearch(_ searchString: String, includeEmpty: Bool = false) -> [SearchToken: SearchTokenData]? {
        // Finds all occurances of token:value or token:(value value...) or token:"value value..."
        let includeEmptyPattern = "([-\\w]+=?):(?:([`](?:[^`]+)*(?: [^`]+)*[`]?)|([\"](?:[^\"]+)*(?: [^\"]+)*[\"]?)|([(](?:[^)]+)*(?: [^)]+)*[)]?)|([^ ]+)|)"
        let regularPattern =      "([-\\w]+=?):(?:[`]([^`]+)[`]|[\"]([^\"]+)[\"]|[(]([^)]+)[)]|([^ ]+))"
        let pattern = includeEmpty ? includeEmptyPattern : regularPattern
        
        // Create the regex object
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch {
            log.severe("Unable to create NSRegularExpression object: \(error)")
        }
        
        if let regex = regex {
            // Search the whole string
            let range = NSRange(location: 0, length: searchString.length)
            
            // Find the matched ranges.
            // Notes: Each match should return 4 ranges, one of which is NSNotFound for some reason. The first range
            // will be the whole match, i.e. in:Visa. The second range will be the token, i.e. in. Then the third and
            // fourth range will be the value and the NSNotFound, depending on whether the token was surrounded by
            // () or "".
            let matches = regex.matches(in: searchString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range)
            var tokens = [SearchToken: SearchTokenData]()
            for match in matches {
                if match.numberOfRanges > 2 {
                    // Find the token
                    let tokenRange = match.range(at: 1)
                    let tokenString = (searchString as NSString).substring(with: tokenRange)
                    if let token = SearchToken(rawValue: tokenString) {
                        // Find the value
                        var valueRange = match.range(at: 2)
                        var i = 3
                        while valueRange.location == NSNotFound && i < match.numberOfRanges {
                            valueRange = match.range(at: i)
                            i += 1
                        }
                        if valueRange.location == NSNotFound {
                            valueRange = NSRange()
                        }
                        
                        var valueString = (searchString as NSString).substring(with: valueRange)
                        if hasTokenPrefix(string: searchString) {
                            if valueString.length > 1 {
                                let range = NSMakeRange(1, valueString.length - 2)
                                valueString = (valueString as NSString).substring(with: range)
                            }
                        }
                        
                        // We got one!
                        let tokenData = SearchTokenData(value: valueString, tokenRange: tokenRange, valueRange: valueRange)
                        tokens[token] = tokenData
                    } else {
                        assert(false,"The token \(tokenString) doesn't have a match on SearchToken class")
//                        assertionFailure("The token \(tokenString) doesn't have a match on SearchToken class")
                    }
                }
            }
            
            if tokens.count > 0 {
                var remainingString = searchString as NSString
                for match in matches.reversed() {
                    if match.numberOfRanges > 3 {
                        let range = match.range(at: 0)
                        remainingString = remainingString.replacingCharacters(in: range, with: "") as NSString
                    }
                }
                remainingString = remainingString.trimmingCharacters(in: CharacterSet.whitespaces) as NSString
                
                if remainingString.length > 0 {
                    // First check if there's an existing name token, and if so, concatonate them
                    if let existingTokenData = tokens[.name] {
                        let value = "\(existingTokenData.value) \(remainingString)"
                        let tokenData = SearchTokenData(value: value, tokenRange: existingTokenData.tokenRange, valueRange: existingTokenData.valueRange)
                        tokens[.name] = tokenData
                    } else {
                        // Just use empty ranges since we don't need to highlight this text anyway
                        let tokenRange = NSRange(location: 0, length: 0)
                        let valueRange = NSRange(location: 0, length: 0)
                        let tokenData = SearchTokenData(value: remainingString as String, tokenRange: tokenRange, valueRange: valueRange)
                        tokens[.name] = tokenData
                    }
                }
                
                return tokens
            }
        }
        
        return nil
    }
    
    static func transactionIdsMatchingTokens(_ tokens: [SearchToken: SearchTokenData]) -> Set<Int> {
        var stringDict = [SearchToken: String]()
        for token in tokens {
            stringDict[token.0] = token.1.value
        }
        return transactionIdsMatchingTokens(stringDict)
    }
    
    // Used for searching to get the fastests results for filtering
    static func transactionIdsMatchingTokens(_ tokens: [SearchToken: String]) -> Set<Int> {
        var transactionIds = Set<Int>()
        database.read.inDatabase { db in
            do {
                func processResult(_ result: FMResultSet?) -> Set<Int> {
                    var ids = Set<Int>()
                    if let result = result {
                        while result.next() {
                            let transactionId = result.long(forColumnIndex: 0)
                            ids.insert(transactionId)
                        }
                        result.close()
                    }
                    return ids
                }
                
                var idSets = [Set<Int>]()
                
                for token in tokens {
                    let value = SearchToken.matchesTokens.contains(token.0) ? "\(token.1)" : "%\(token.1)%"
                    let like = SearchToken.notTokens.contains(token.0) ? "NOT LIKE" : "LIKE"
                    
                    var result: FMResultSet?
                    switch token.0 {
                    case .in, .account, .accountMatches, .inNot, .accountNot, .accountMatchesNot:
                        let statement = "SELECT transactionId FROM transactions " +
                                        "JOIN accounts ON transactions.accountId = accounts.accountId " +
                                        "JOIN institutions ON accounts.institutionId = institutions.institutionId " +
                                        "WHERE transactions.accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) AND " +
                                        "(accounts.name \(like) ? OR institutions.name \(like) ?) " +
                                        "COLLATE NOCASE"
                        result = try db.executeQuery(statement, value, value)
                        idSets.append(processResult(result))
                    case .category, .categoryNot, .categoryMatches, .categoryMatchesNot:
                        let value = token.0 == .categoryMatches ? "\(token.1)" : "%\(token.1)%"
                        let statement = "SELECT transactionId FROM transactions " +
                                        "JOIN categories ON transactions.categoryId = categories.categoryId " +
                                        "WHERE transactions.accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) AND " +
                                        "(categories.name1 LIKE ? COLLATE NOCASE OR categories.name2 LIKE ? COLLATE NOCASE OR categories.name3 LIKE ? COLLATE NOCASE)"
                        result = try db.executeQuery(statement, value, value, value)
                        idSets.append(processResult(result))
                    case .name, .nameNot, .nameMatches, .nameMatchesNot:
                        let statement = "SELECT transactionId FROM transactions " +
                                        "WHERE accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) AND " +
                                        "name \(like) ? COLLATE NOCASE"
                        result = try db.executeQuery(statement, value, value, value)
                        idSets.append(processResult(result))
                    case .amount, .amountNot, .under, .over:
                        if let cents = stringToCents(token.1) {
                            var comparison = "="
                            if token.0 == .amountNot {
                                comparison = "!="
                            } else if token.0 == .under {
                                comparison = "<"
                            } else if token.0 == .over {
                                comparison = ">"
                            }
                            let statement = "SELECT transactionId FROM transactions " +
                                            "WHERE accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) AND " +
                                            "ABS(amount) \(comparison) ?"
                            result = try db.executeQuery(statement, cents)
                            idSets.append(processResult(result))
                        } else {
                            idSets.append(Set<Int>())
                        }
                    case .when, .whenNot:
                        var comparison = token.0 == .when ? "=" : "!="
                        var value: Double?
                        let lowercase = token.1.lowercased()
                        if lowercase == "today" {
                            value = Date.today().timeIntervalSince1970
                        } else if lowercase == "yesterday" {
                            value = Date.yesterday().timeIntervalSince1970
                        } else if lowercase == "tomorrow" {
                            value = Date.tomorrow().timeIntervalSince1970
                        } else if lowercase == "this week" {
                            comparison = token.0 == .when ? ">" : "<"
                            value = Date.firstDayOfWeek().timeIntervalSince1970
                        } else if lowercase == "this month" {
                            comparison = token.0 == .when ? ">" : "<"
                            value = Date.firstOfMonth().timeIntervalSince1970
                        } else if lowercase == "this year" {
                            comparison = token.0 == .when ? ">" : "<"
                            value = Date.firstOfYear().timeIntervalSince1970
                        } else {
                            let array = lowercase.components(separatedBy: " ")
                            if array.count >= 2 && array[1].hasPrefix("days"), let days = Double(array[0]) {
                                comparison = token.0 == .when ? ">" : "<"
                                value = Date.today().addingTimeInterval(-3600 * 24 * days).timeIntervalSince1970
                            } else {
                                var array = lowercase.components(separatedBy: "/")
                                if array.count != 3 {
                                    array = lowercase.components(separatedBy: "-")
                                }
                                
                                if array.count == 3, let month = Int(array[0]), let day = Int(array[1]), let year = Int(array[2]) {
                                    var comps = DateComponents()
                                    comps.month = month
                                    comps.day = day
                                    comps.year = year < 100 ? year + 2000 : year
                                    if let date = Calendar.current.date(from: comps) {
                                        value = date.timeIntervalSince1970
                                    }
                                }
                            }
                        }
                        
                        if let value = value {
                            let statement = "SELECT transactionId FROM transactions " +
                                            "WHERE accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) AND " +
                                            "DATE(date, 'unixepoch', 'localtime') \(comparison) DATE(\(value), 'unixepoch', 'localtime')"
                            result = try db.executeQuery(statement)
                            idSets.append(processResult(result))
                        }
                    case .before, .after:
                        var value: Double?
                        let lowercase = token.1.lowercased()
                        if lowercase == "today" {
                            value = Date.today().timeIntervalSince1970
                        } else if lowercase == "yesterday" {
                            value = Date.yesterday().timeIntervalSince1970
                        } else if lowercase == "tomorrow" {
                            value = Date.tomorrow().timeIntervalSince1970
                        } else if lowercase == "this week" {
                            value = Date.firstDayOfWeek().timeIntervalSince1970
                        } else if lowercase == "this month" {
                            value = Date.firstOfMonth().timeIntervalSince1970
                        } else if lowercase == "this year" {
                            value = Date.firstOfYear().timeIntervalSince1970
                        } else {
                            let array = lowercase.components(separatedBy: " ")
                            if array.count >= 2 && array[1].hasPrefix("days"), let days = Double(array[0]) {
                                value = Date.today().addingTimeInterval(-3600 * 24 * days).timeIntervalSince1970
                            } else {
                                var array = lowercase.components(separatedBy: "/")
                                if array.count != 3 {
                                    array = lowercase.components(separatedBy: "-")
                                }
                                
                                if array.count == 3, let month = Int(array[0]), let day = Int(array[1]), let year = Int(array[2]) {
                                    var comps = DateComponents()
                                    comps.month = month
                                    comps.day = day
                                    comps.year = year < 100 ? year + 2000 : year
                                    if let date = Calendar.current.date(from: comps) {
                                        value = date.timeIntervalSince1970
                                    }
                                }
                            }
                        }
                        
                        if let value = value {
                            let comparison = (token.0 == .after ? ">" : "<")
                            let statement = "SELECT transactionId FROM transactions " +
                                            "WHERE accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) AND " +
                                            "DATE(date, 'unixepoch', 'localtime') \(comparison) DATE(\(value), 'unixepoch', 'localtime')"
                            result = try db.executeQuery(statement)
                            idSets.append(processResult(result))
                        }
                    }
                }
                
                // Only return ids that matched every token
                let count = idSets.count
                if count > 0 {
                    var finalSet = idSets[0]
                    if count > 1 {
                        for i in 1...count-1 {
                            let ids = idSets[i]
                            finalSet = finalSet.intersection(ids)
                        }
                    }
                    transactionIds = finalSet
                }
                
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        return transactionIds
    }
        
    static func filterTransactions<T>(data: [T], searchString: String) -> [T] {
        let filtered: [T]
        
        if let tokens = Search.tokenizeSearch(searchString) {
            // Perform a token search
            let transactionIds = Search.transactionIdsMatchingTokens(tokens)
            filtered = data.filter { transaction -> Bool in
                if let transaction = transaction as? Transaction {
                    return transactionIds.contains(transaction.transactionId)
                } else {
                    return true
                }
            }
        } else {
            // Perform a regular search
            filtered = data.filter { item -> Bool in
                if let transaction = item as? Transaction {
                    return transaction.name.lowercased().contains(searchString)
                } else {
                    return true
                }
            }
        }
        
        // Remove extra header models from the results
        var final = [T]()
        var lastObject: T?
        for object in filtered {
            if (lastObject is NSDate || lastObject is String) && (object is Date || object is String) {
                // Two header models in a row means we don't need the first one
                final.removeLast()
            }
            
            lastObject = object
            final.append(object)
        }
        if final.last is NSDate || final.last is String {
            final.removeLast()
        }
        
        return final
    }
    
    static func filterTransactions<K, V>(data: OrderedDictionary<K, [V]>, searchString: String) -> (transactions: OrderedDictionary<K, [V]>, counts: [Int]) {
        var filtered = OrderedDictionary<K, [V]>()
        var counts = [Int]()
        
        if let tokens = Search.tokenizeSearch(searchString) {
            // Perform a token search
            let transactionIds = Search.transactionIdsMatchingTokens(tokens)
            let originalSections = data.keys
            for section in originalSections {
                if let transactions = data[section] {
                    let filteredTransactions = transactions.filter { transaction -> Bool in
                        if let transaction = transaction as? Transaction {
                            return transactionIds.contains(transaction.transactionId)
                        } else {
                            return true
                        }
                    }
                    if filteredTransactions.count > 0 {
                        filtered[section] = filteredTransactions
                        counts.append(filteredTransactions.count)
                    }
                }
            }
        } else {
            // Perform a regular search
            let originalSections = data.keys
            for section in originalSections {
                if let transactions = data[section] {
                    let lowerCasedSearchString = searchString.lowercased()
                    let filteredTransactions = transactions.filter { transaction -> Bool in
                        if let transaction = transaction as? Transaction {
                            return transaction.name.lowercased().contains(lowerCasedSearchString)
                        } else {
                            return true
                        }
                    }
                    if filteredTransactions.count > 0 {
                        filtered[section] = filteredTransactions
                        counts.append(filteredTransactions.count)
                    }
                }
            }
        }
        
        return (filtered, counts)
    }
    
    
    #if os(OSX)
    // Poor man's NSTokenField. This highlights the tokens and values to look better than plain text
    // See http://stackoverflow.com/questions/16362407/nsattributedstring-background-color-and-rounded-corners and
    // https://github.com/MrMatthias/BackgroundDrawingAttribute/blob/master/BackgroundDrawingAttribute/BackgroundAttributeView.swift
    // for examples of rounding the corners. Will need to implement custom search field first to do our own text rendering or possibly
    // look into hooking NSSearchField's drawing code
    static func styleSearchString(_ searchString: String, textColor: NSColor = CurrentTheme.defaults.searchField.textColor, font: NSFont = CurrentTheme.defaults.searchField.font, colorTokenAndValueSeparately: Bool = false) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: searchString)
        let initialAttributes = [NSAttributedStringKey.foregroundColor: textColor,
                                 NSAttributedStringKey.font: font]
        attributed.addAttributes(initialAttributes, range: NSRange(location: 0, length: searchString.length))
        
        if let tokens = Search.tokenizeSearch(searchString, includeEmpty: true) {
            for token in tokens {
                let tokenData = token.value
                if colorTokenAndValueSeparately {
                    // Style the token
                    let tokenAttributes = [TokenTextField.LeftRoundedBackgroundColorAttributeName: NSColor.purple]
                    // Account for the : after the token
                    var tokenRange = tokenData.tokenRange
                    if tokenRange.length > 0 {
                        tokenRange.length += 1
                        attributed.addAttributes(tokenAttributes, range: tokenRange)
                        
                        if tokenData.valueRange.length > 0 {
                            // Add spacing after the :
                            let colonSpacingAttributes = [NSAttributedStringKey.kern: 5.0]
                            var colonRange = tokenData.tokenRange
                            colonRange.location += colonRange.length
                            colonRange.length = 1
                            attributed.addAttributes(colonSpacingAttributes, range: colonRange)
                        }
                        
                        if tokenData.valueRange.length > 0 {
                            // Style the value
                            let valueAttributes = [TokenTextField.RightRoundedBackgroundColorAttributeName: NSColor.yellow]
                            // Account for ( or " before and after the token
                            var valueRange = tokenData.valueRange
                            if valueRange.location > tokenRange.location + tokenRange.length {
                                valueRange.location -= 1
                                valueRange.length += hasTokenSuffix(string: tokenData.value) ? 2 : 1
                            }
                            attributed.addAttributes(valueAttributes, range: valueRange)
                            
                            //                        // Add spacing after the value
                            //                        let endSpacingAttributes = [NSKernAttributeName: 3.0]
                            //                        var endRange = valueRange
                            //                        endRange.location += endRange.length - 1
                            //                        endRange.length = 1
                            //                        attributed.addAttributes(endSpacingAttributes, range: endRange)
                            //                        print("valueRange: \(valueRange.location) endRange: \(endRange.location)")
                        }
                    }
                } else if tokenData.tokenRange.length > 0 {
                    var totalRange = NSUnionRange(tokenData.tokenRange, tokenData.valueRange)
                    if tokenData.valueRange.length == 0 {
                        // Add one to the length for the semicolon when there is no value and fix the location
                        totalRange = tokenData.tokenRange
                        totalRange.length += 1
                    }
                    
                    // Account for )/"/' after the token
                    if tokenData.valueRange.location > tokenData.tokenRange.location + tokenData.tokenRange.length + 1 {
                        totalRange.length += hasTokenSuffix(string: tokenData.value) ? 1 : 0
                    }
                    
                    // Set the background color
                    if let color = searchTokenBackgroundColors[token.key] {
                        let totalAttributes = [TokenTextField.RoundedBackgroundColorAttributeName: color,
                                               NSAttributedStringKey.foregroundColor: searchTokenTextColor] as [AnyHashable : PXColor]
                        attributed.addAttributes(totalAttributes as! [NSAttributedStringKey : Any], range: totalRange)
                    }
                    
                    // Add spacing at the start
                    if totalRange.location > 0 {
                        let endSpacingAttributes = [NSAttributedStringKey.kern: 6.0]
                        var startRange = totalRange
                        startRange.location -= 1
                        startRange.length = 1
                        attributed.addAttributes(endSpacingAttributes, range: startRange)
                    }
                    
                    // Add spacing at the end
                    if searchString.length > totalRange.location + totalRange.length {
                        let endSpacingAttributes = [NSAttributedStringKey.kern: 6.0]
                        var endRange = totalRange
                        endRange.location += endRange.length
                        endRange.length = 1
                        attributed.addAttributes(endSpacingAttributes, range: endRange)
                    }
                }
            }
        }
        
        return attributed
    }
    #endif
    
    static func hasTokenPrefix(string: String) -> Bool {
        return string.hasPrefix("(") || string.hasPrefix("\"")
    }
    
    static func hasTokenSuffix(string: String) -> Bool {
        return string.hasSuffix(")") || string.hasSuffix("\"")
    }
    
    static func convertToSearchTokenStrings(fromTokens tokens: [SearchToken: SearchTokenData]) -> [SearchToken: String] {
        var stringDict = [SearchToken: String]()
        for (token, tokenData) in tokens {
            stringDict[token] = tokenData.value
        }
        return stringDict
    }
    
    static func createSearchString(forTokens tokens: [SearchToken: String]) -> String {
        var searchString = ""
        for token in SearchToken.orderedTokens {
            if token != .name, let value = tokens[token] {
                searchString += "\(token.rawValue):"
                searchString += value.contains(" ") ? "`\(value)` " : "\(value) "
            }
        }
        
        if let value = tokens[.name] {
            searchString += value
        }
        
        return searchString
    }
    
    static func searchTransactions(accountOrInstitutionName: String) {
        let token = SearchToken.accountMatches.rawValue
        let name = accountOrInstitutionName.capitalizedStringIfAllCaps
        let searchString = "\(token):`\(name)`"
        NotificationCenter.postOnMainThread(name: Notifications.PerformSearch, object: nil, userInfo: [Notifications.Keys.SearchString: searchString])
    }
}
