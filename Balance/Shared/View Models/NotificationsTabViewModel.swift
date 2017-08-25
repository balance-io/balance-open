//
//  NotificationsTabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

@objc protocol NotificationsTabViewModelDelegate {
    func reloadDataFinished()
}

class NotificationsTabViewModel: TabViewModel {
    
    weak var delegate: NotificationsTabViewModelDelegate?
    
    var dataChangedInBackground = false
    
    // MARK: Search
    var searching = false
    var data = OrderedDictionary<Date, [Transaction]>()
    var unfilteredData = OrderedDictionary<Date, [Transaction]>()
    var lastSearch = OrderedDictionary<Date, [Transaction]>()
    var reloadAfterSearch = false // In case data changes during searching

    func reloadData() {
        if searching {
            reloadAfterSearch = true
        } else {
            DispatchQueue.userInteractive.async {
                let allTransactions = feed.transactionsbyDate(transactions: feed.allMatchingTransactions())
                DispatchQueue.main.async {
                    // Check again to see if we're searching just in case they just started
                    if self.searching {
                        self.reloadAfterSearch = true
                    } else {
                        self.unfilteredData = allTransactions
                        self.data = self.unfilteredData
                        self.lastSearch = self.unfilteredData
                        
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
        if let transactions = data[section] {
            return transactions.count
        }
        return 0
    }
    
    func performSearchNow(searchString: String) {
        searching = true
        
        // Perform the search
        if searchString.isEmpty {
            searching = false
            data = unfilteredData
            
            if reloadAfterSearch {
                reloadData()
            }
        } else {
            let searchString = searchString.lowercased()
            data = Search.filterTransactions(data: unfilteredData, searchString: searchString).transactions
        }
        
        lastSearch = data
    }
}
