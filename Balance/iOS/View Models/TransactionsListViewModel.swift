//
//  TransactionsListViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 03/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import NSDateTimeAgo


internal protocol TransactionsListViewModelDelegate: class {
    func didReloadData(in viewModel: TransactionsListViewModel)
}


internal final class TransactionsListViewModel {
    // Internal
    internal weak var delegate: TransactionsListViewModelDelegate?
    
    internal var numberOfSections: Int {
        return self.transactions.count
    }
    
    // Private
    private var transactions = OrderedDictionary<Date, [Transaction]>()
    private var sectionRowCounts = [Int]()
    
    // MARK: Initialization
    
    internal required init() {
        // Notifications
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(self.syncCompletedNotification(_:)), name: Notifications.SyncCompleted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(self.institutionRemovedNotification(_:)), name: Notifications.InstitutionRemoved)
        
        self.reloadData()
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self)
    }
    
    // MARK: Data
    
    private func reloadData() {
        let transactionsByDate = TransactionRepository.si.transactionsByDate()
        self.transactions = transactionsByDate.transactions
        self.sectionRowCounts = transactionsByDate.counts
        
        self.delegate?.didReloadData(in: self)
    }
    
    // MARK: API
    
    internal func numberOfRows(at section: Int) -> Int {
        return self.sectionRowCounts[section]
    }
    
    internal func title(for section: Int) -> String {
        let date = self.transactions.keys[section]
        return date.timeAgo
    }
    
    internal func transaction(at indexPath: IndexPath) -> Transaction {
        // Force unwrapped because the programmer is doing something wrong if this is raised
        let section = self.transactions[indexPath.section]!
        return section[indexPath.row]
    }
    
    // MARK: Notifications
    
    @objc private func syncCompletedNotification(_ notification: Notification) {
        self.reloadData()
    }
    
    @objc private func institutionRemovedNotification(_ notification: Notification) {
        self.reloadData()
    }
}
