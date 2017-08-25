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
                DispatchQueue.main.async {
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
