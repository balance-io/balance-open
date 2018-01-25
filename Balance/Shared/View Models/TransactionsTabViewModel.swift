//
//  TransactionsTabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

@objc protocol TransactionsTabViewModelDelegate {
    func reloadDataFinished()
}

class TransactionsTabViewModel: TabViewModel {
    
    weak var delegate: TransactionsTabViewModelDelegate?
    
    var dataChangedInBackground = false
    var searching = false
    var searchTokens = [SearchToken: String]()
    var data = OrderedDictionary<Date, [Transaction]>()
    var dataCounts = [Int]()
    var unfilteredData = OrderedDictionary<Date, [Transaction]>()
    var unfilteredDataCounts = [Int]()
    var lastSearch = OrderedDictionary<Date, [Transaction]>()
    var reloadAfterSearch = false // In case data changes during searching
    var minTransactionAmount = 0
    var maxTransactionAmount = 0
    
    var accounts: [String] { return ["All Accounts"] + InstitutionRepository.si.allInstitutions(sorted: true).map({$0.name}) }
    var categories: [String] { return ["All Categories"] + CategoryRepository.si.allCategoryNames() }
    let times = ["All Time", "30 Days", "90 Days", "This Week", "This Month", "This Year"]
    let amounts = ["Any Amount", "Under $10", "Under $100", "Over $500", "Under $500 and Over $100"]
    
    func reloadData() {
        if searching {
            reloadAfterSearch = true
        } else {
            DispatchQueue.userInteractive.async {
                let allTransactions = TransactionRepository.si.transactionsByDate()
                async {
                    // Check again to see if we're searching just in case they just started
                    if self.searching {
                        self.reloadAfterSearch = true
                    } else {
                        self.unfilteredData = allTransactions.transactions
                        self.data = self.unfilteredData
                        self.lastSearch = self.unfilteredData
                        self.dataCounts = allTransactions.counts
                        self.unfilteredDataCounts = self.dataCounts
                        self.minTransactionAmount = TransactionRepository.si.minTransactionAmount()
                        self.maxTransactionAmount = TransactionRepository.si.maxTransactionAmount()
                        
                        self.delegate?.reloadDataFinished()
                    }
                }
            }
        }
    }
    
    func numberOfSections() -> Int {
        return data.count
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        if section < dataCounts.count {
            return dataCounts[section]
        }
        return 0
    }
    
    func sectionTitle(for section: Int) -> String {
        if section < data.keys.count {
            let date = data.keys[section]
            return sectionDateToString(date: date)
        }
        return ""
    }
    
    func transaction(forRow row: Int, inSection section: Int) -> Transaction {
        return data[section]![row]
    }
    
    private let dateFormatter = DateFormatter()
    private func sectionDateToString(date: Date) -> String {
        var dateString = ""
        
        let calendar = Calendar.current
        let currentYear = (calendar as NSCalendar).component(.year, from: Date())
        
        if calendar.isDateInToday(date) {
            dateString = "Today"
        } else if calendar.isDateInYesterday(date) {
            dateString = "Yesterday"
        } else {
            let year = (Calendar.current as NSCalendar).component(.year, from: date)
            if year < currentYear {
                dateFormatter.dateFormat = "EEEE MMM d y"
            } else {
                dateFormatter.dateFormat = "EEEE MMM d"
            }
            
            dateString = dateFormatter.string(from: date)
        }
        
        return dateString.uppercased()
    }
    
    func performSearchNow(searchString: String) {
        searching = true
        
        // Perform the search
        if searchString.isEmpty {
            searching = false
            data = unfilteredData
            dataCounts = unfilteredDataCounts
            searchTokens = [SearchToken: String]()
            
            if reloadAfterSearch {
                reloadData()
            }
        } else {
            let result = Search.filterTransactions(data: unfilteredData, searchString: searchString)
            data = result.transactions
            dataCounts = result.counts
            if let newSearchTokens = Search.tokenizeSearch(searchString) {
                searchTokens = Search.convertToSearchTokenStrings(fromTokens: newSearchTokens)
            } else {
                searchTokens = [SearchToken.name: searchString]
            }
        }
        
        lastSearch = data
    }
}
