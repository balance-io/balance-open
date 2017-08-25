//
//  InsightsTabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

@objc protocol InsightsTabViewModelDelegate {
    func reloadDataFinished()
    func selectRange(index: Int)
}

class InsightsTabViewModel: TabViewModel {
    
    enum DisplayMode: Int {
        case topMerchants    = 0
        case newMerchants    = 1
        
        static func displayModeStrings() -> [String] {
            return ["Spending", "New Merchants"]
        }
    }
    
    enum NewMerchantsRange: Int {
        case eachWeek       = 0
        case eachMonth      = 1
        
        static func strings() -> [String] {
            return ["By Week", "By Month"]
        }
    }
    
    enum TopMerchantsRange: Int {
        case past30Days     = 0
        case past90Days     = 1
        case thisWeek       = 2
        case thisMonth      = 3
        case thisYear       = 4
        case allTime        = 5
        
        static func strings() -> [String] {
            return ["Past 30 Days", "Past 90 Days", "This Week", "This Month", "This Year", "All Time"]
        }
    }
    
    weak var delegate: InsightsTabViewModelDelegate?
    
    var displayMode = DisplayMode.topMerchants
    var newMerchantsRange = NewMerchantsRange.eachWeek
    var topMerchantsRange = TopMerchantsRange.past30Days
    
    var dataChangedInBackground = false
    
    var searching = false
    var reloadAfterSearch = false // In case data changes during searching
    
    var newMerchantsData = [OrderedDictionary<Date, [Transaction]>]()
    var unfilteredNewMerchantsData = [OrderedDictionary<Date, [Transaction]>]()
    var lastNewMerchantsSearch = OrderedDictionary<Date, [Transaction]>()
    
    var topMerchantsData = [[Merchant]]()
    var topMerchantsMaxAmounts = [Int]()
    var unfilteredTopMerchantsData = [[Merchant]]()
    var lastTopMerchantsSearch = [Merchant]()
    
    func reloadData() {
        if searching {
            reloadAfterSearch = true
        } else {
            DispatchQueue.utility.async {
                let merchantWeeklyData = insights.newMerchantsByWeek()
                let merchantMonthlyData = insights.newMerchantsByMonth()
                let totalSpendingPast30Days = insights.totalSpendingPerMerchantPastDays(30)
                let totalSpendingPast90Days = insights.totalSpendingPerMerchantPastDays(90)
                let totalSpendingThisWeek = insights.totalSpendingPerMerchantThisWeek()
                let totalSpendingThisMonth = insights.totalSpendingPerMerchantThisMonth()
                let totalSpendingThisYear = insights.totalSpendingPerMerchantThisYear()
                let totalSpendingAllTime = insights.totalSpendingPerMerchant()
                
                DispatchQueue.main.async {
                    self.newMerchantsData = [merchantWeeklyData, merchantMonthlyData]
                    self.unfilteredNewMerchantsData = self.newMerchantsData
                    self.lastNewMerchantsSearch = self.newMerchantsData[self.newMerchantsRange.rawValue]
                    
                    self.topMerchantsData = [totalSpendingPast30Days, totalSpendingPast90Days, totalSpendingThisWeek, totalSpendingThisMonth, totalSpendingThisYear, totalSpendingAllTime]
                    var maxAmounts = [Int]()
                    for totals in self.topMerchantsData {
                        let maxAmount = totals.first?.amountTotal ?? 0
                        maxAmounts.append(maxAmount)
                    }
                    self.topMerchantsMaxAmounts = maxAmounts
                    self.unfilteredTopMerchantsData = self.topMerchantsData
                    self.lastTopMerchantsSearch = self.topMerchantsData[self.topMerchantsRange.rawValue]
                    
                    self.delegate?.reloadDataFinished()
                    
                    // If the default section is empty, iterate until we find a section with records
                    var i = 0
                    if self.displayMode == .topMerchants {
                        for merchants in self.topMerchantsData {
                            if merchants.count > 0 {
                                break
                            }
                            i += 1
                        }
                        
                        let count = self.topMerchantsData.count
                        if i >= count {
                            i = count - 1
                        }
                    } else if self.displayMode == .newMerchants {
                        for merchants in self.newMerchantsData {
                            if merchants.count > 0 {
                                break
                            }
                            i += 1
                        }
                        
                        let count = self.newMerchantsData.count
                        if i >= count {
                            i = count - 1
                        }
                    }
                    
                    if i != 0 {
                        self.delegate?.selectRange(index: i)
                    }
                }
            }
        }
    }
    
    func numberOfSections() -> Int {
        switch displayMode {
        case .topMerchants:
            return 1
        case .newMerchants:
            return newMerchantsData.count > 0 ? newMerchantsData[newMerchantsRange.rawValue].count : 0
        }
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        switch displayMode {
        case .topMerchants:
            guard topMerchantsData.count > 0 else {
                return 0
            }
            return topMerchantsData[topMerchantsRange.rawValue].count
        case .newMerchants:
            guard newMerchantsData[newMerchantsRange.rawValue].count > 0, let transactions = newMerchantsData[newMerchantsRange.rawValue][section] else {
                return 0
            }
            return transactions.count
        }
    }
    
    func performMerchantSearch(searchString: String) {
        var whenString: String?
        switch topMerchantsRange {
        case .past30Days:  whenString = "30 days"
        case .past90Days:  whenString = "90 days"
        case .thisWeek:    whenString = "this week"
        case .thisMonth:   whenString = "this month"
        case .thisYear:    whenString = "this year"
        case .allTime: break
        }
        
        var finalSearchString = searchString
        if let whenString = whenString {
            finalSearchString += " \(SearchToken.when.rawValue):\"\(whenString)\""
        }
        
        NotificationCenter.postOnMainThread(name: Notifications.PerformSearch, object: nil, userInfo: [Notifications.Keys.SearchString: finalSearchString])
    }
}
