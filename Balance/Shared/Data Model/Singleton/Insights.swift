//
//  Insights.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

@objc class Merchant: NSObject {
    let name: String
    let amountTotal: Int
    let numberOfTransactions: Int
    
    init(name: String, amountTotal: Int, numberOfTransactions: Int) {
        self.name = name
        self.amountTotal = amountTotal
        self.numberOfTransactions = numberOfTransactions
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Merchant {
            return self == object
        }
        return false
    }
}

func ==(lhs: Merchant, rhs: Merchant) -> Bool {
    return lhs.name == rhs.name
}

class Insights {
    /* // Commenting these out for now to speed up compile time, this one was taking a full second
    func spendingTotalByDay(_ days: Int) -> [Date: Int] {
        let dayString: (Date) -> String = { date in
            let components = (Calendar.current as NSCalendar).components([.year, .month, .day], from: date)
            return "\(components.year)-\(components.month)-\(components.day)"
        }
        
        var dayTotals = [Date: Int]()
        var dayStrings = Set<String>()
        database.read.inDatabase { db in
            do {
                let statement = "SELECT date, SUM(amount) FROM transactions " +
                                "WHERE DATE(date, 'unixepoch', 'localtime') >= DATE('now','-\(days) days', 'localtime')" +
                                "AND amount > 0 GROUP BY DATE(date, 'unixepoch', 'localtime')"
                let result = try db.executeQuery(statement)
                while result.next() {
                    let date = result.date(forColumnIndex: 0)!
                    let cents = result.long(forColumnIndex: 1)
                    dayTotals[date] = cents
                    dayStrings.insert(dayString(date))
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        // Fill in the missing days if necessary
        if dayTotals.count < days {
            for i in 0...days-1 {
                // Calculate the day string for each of the past n days
                let interval = Double(-i * 60 * 60 * 24)
                let date = Date(timeIntervalSinceNow:interval)
                if !dayStrings.contains(dayString(date)) {
                    // No total for this date, so add 0
                    dayTotals[date] = 0
                    print("Added 0 total for \(dayString(date))")
                }
            }
        }
        return dayTotals
    }
    
    func incomeAndSpendingTotalByMonth(_ months: Int) -> [Date: (income: Int, spending: Int)] {
        let monthString: (Date) -> String = { date in
            let components = (Calendar.current as NSCalendar).components([.year, .month], from: date)
            return "\(components.year)-\(components.month)"
        }
        
        var incomeTotals = [String: (date: Date, total: Int)]()
        var spendingTotals = [String: (date: Date, total: Int)]()
        database.read.inDatabase { db in
            do {
                var statement = "SELECT date, SUM(amount) FROM transactions " +
                                "WHERE DATE(date, 'unixepoch', 'localtime') >= DATE('now','-6 months', 'localtime') " +
                                "AND amount < 0 GROUP BY STRFTIME('%Y-%m', date, 'unixepoch', 'localtime')"
                var result = try db.executeQuery(statement)
                while result.next() {
                    let date = result.date(forColumnIndex: 0)!
                    let cents = result.long(forColumnIndex: 1)
                    let month = monthString(date)
                    incomeTotals[month] = (date: date, total: cents)
                }
                result.close()
                
                statement = "SELECT date, SUM(amount) FROM transactions " +
                            "WHERE DATE(date, 'unixepoch', 'localtime') >= DATE('now','-6 months', 'localtime') " +
                            "AND amount > 0 GROUP BY STRFTIME('%Y-%m', date, 'unixepoch', 'localtime')"
                result = try db.executeQuery(statement)
                while result.next() {
                    let date = result.date(forColumnIndex: 0)!
                    let cents = result.long(forColumnIndex: 1)
                    let month = monthString(date)
                    spendingTotals[month] = (date: date, total: cents)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        // Fill in the missing months if necessary
        if incomeTotals.count < months || spendingTotals.count < months {
            let incomeStrings = Set(incomeTotals.keys)
            let spendingStrings = Set(incomeTotals.keys)
            
            let now = Date()
            for i in 0...months-1 {
                var offset = DateComponents()
                offset.month = -i
                let date = (Calendar.current as NSCalendar).date(byAdding: offset, to: now, options: [])!
                let month = monthString(date)
                if !incomeStrings.contains(month) {
                    incomeTotals[month] = (date: date, total: 0)
                }
                if !spendingStrings.contains(month) {
                    spendingTotals[month] = (date: date, total: 0)
                }
            }
        }
        
        // Merge the data
        var totals = [Date: (income: Int, spending: Int)]()
        let now = Date()
        for i in 0...months-1 {
            var offset = DateComponents()
            offset.month = -i
            let date = (Calendar.current as NSCalendar).date(byAdding: offset, to: now, options: [])!
            let month = monthString(date)
            
            if let income = incomeTotals[month], let spending = spendingTotals[month] {
                let total = (income: income.total, spending: spending.total)
                totals[date] = total
            }
        }
        
        print(totals)
        return totals
    }*/
    
    // New merchants by week (keyed by week start date)
    func newMerchantsByWeek() -> OrderedDictionary<Date, [Transaction]> {
        var newMerchantsByWeek = OrderedDictionary<Date, [Transaction]>()
        if let oldestTransactionDate = TransactionRepository.si.oldestTransaction()?.date {
            var previousFirstDayOfWeek = Date.firstDayOfWeek()
            while (previousFirstDayOfWeek as NSDate).laterDate(oldestTransactionDate) == previousFirstDayOfWeek {
                // Process the transactions
                let endDate = previousFirstDayOfWeek.addingTimeInterval(3600.0 * 24 * 6)
                let transactions = TransactionRepository.si.transactionsFromNewMerchantsInDateRange(previousFirstDayOfWeek, endDate: endDate)
                if transactions.count > 0 {
                    newMerchantsByWeek[previousFirstDayOfWeek] = transactions
                }
                
                // Calculate the next previous first day of the week
                previousFirstDayOfWeek = Date.firstDayOfWeek(previousFirstDayOfWeek.addingTimeInterval(-3600.0 * 24))
            }
        }
        
        return newMerchantsByWeek
    }
    
    // New merchants by month (keyed by month start date)
    func newMerchantsByMonth() -> OrderedDictionary<Date, [Transaction]> {
        var newMerchantsByMonth = OrderedDictionary<Date, [Transaction]>()
        if let oldestTransactionDate = TransactionRepository.si.oldestTransaction()?.date {
            var firstOfMonth = Date.firstOfMonth()
            while (firstOfMonth as NSDate).laterDate(oldestTransactionDate) == firstOfMonth {
                // Process the transactions
                let endOfMonth = Date.endOfMonth(firstOfMonth)
                let transactions = TransactionRepository.si.transactionsFromNewMerchantsInDateRange(firstOfMonth, endDate: endOfMonth)
                if transactions.count > 0 {
                    newMerchantsByMonth[firstOfMonth] = transactions
                }
                
                // Calculate the next previous sunday
                let previousEndOfMonth = firstOfMonth.addingTimeInterval(-1)
                firstOfMonth = Date.firstOfMonth(previousEndOfMonth)
            }
        }
        
        return newMerchantsByMonth
    }
    
    // Total spending by merchant
    func totalSpendingPerMerchant(startDate: Date = Date.distantPast, endDate: Date = Date.distantFuture, includeHidden: Bool = false) -> [Merchant] {
        var totalSpendingPerMerchant = [Merchant]()
        
        database.read.inDatabase { db in
            do {
                let dateSql = "DATE(?, 'unixepoch', 'localtime')"
                var statement = "SELECT name, sum(amount) AS summedAmount, count(name) " +
                                "FROM transactions "  +
                                "WHERE amount > 0 AND DATE(date, 'unixepoch', 'localtime') BETWEEN \(dateSql) AND \(dateSql) "
                if !includeHidden {
                    statement += "AND accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) "
                }
                statement += "GROUP BY name ORDER BY summedAmount DESC"
                
                let result = try db.executeQuery(statement, startDate.timeIntervalSince1970, endDate.timeIntervalSince1970)
                while result.next() {
                    let name = result.string(forColumnIndex: 0)!
                    let amount = result.long(forColumnIndex: 1)
                    let count = result.long(forColumnIndex: 2)
                    let merchant = Merchant(name: name, amountTotal: amount, numberOfTransactions: count)
                    totalSpendingPerMerchant.append(merchant)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        let exceptions = ["uber": "Uber", "atm": "ATM"]
        for exception in exceptions {
            var matchingMerchants = [Merchant]()
            for merchant in totalSpendingPerMerchant {
                if merchant.name.lowercased().contains(exception.0) {
                    matchingMerchants.append(merchant)
                }
            }
            
            if matchingMerchants.count > 1 {
                // Calculate the total
                let totalAmount = matchingMerchants.reduce(0, {$0 + $1.amountTotal})
                let totalTransactions = matchingMerchants.reduce(0, {$0 + $1.numberOfTransactions})
                
                // Remove the old merchant names
                for merchant in matchingMerchants {
                    if let index = totalSpendingPerMerchant.index(of: merchant) {
                        totalSpendingPerMerchant.remove(at: index)
                    }
                }
                
                // Add the new merchant name
                let totaledMerchant = Merchant(name: exception.1, amountTotal: totalAmount, numberOfTransactions: totalTransactions)
                totalSpendingPerMerchant.append(totaledMerchant)
                
                // Sort the results by amount descending
                totalSpendingPerMerchant.sort(by: {$0.amountTotal > $1.amountTotal})
            }
        }
        
        return totalSpendingPerMerchant
    }
    
    func totalSpendingPerMerchantThisWeek() -> [Merchant] {
        let date = Date.firstDayOfWeek()
        return totalSpendingPerMerchant(startDate: date)
    }
    
    func totalSpendingPerMerchantThisMonth() -> [Merchant] {
        let date = Date.firstOfMonth()
        return totalSpendingPerMerchant(startDate: date)
    }
    
    func totalSpendingPerMerchantThisYear() -> [Merchant] {
        let date = Date.firstOfYear()
        return totalSpendingPerMerchant(startDate: date)
    }
    
    func totalSpendingPerMerchantPastDays(_ days: Int) -> [Merchant] {
        let date = Date().addingTimeInterval(-3600.0 * 24.0 * Double(days))
        return totalSpendingPerMerchant(startDate: date)
    }
}
