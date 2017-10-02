//
//  ViewController.swift
//  balanceios
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

class AccountsTabViewController: UITableViewController {
    
    let viewModel = AccountsTabViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary
        tableView.contentInset.top = UIApplication.shared.statusBarFrame.height
        
        reloadData()
        
        registerForNotifications()
    }
    
    deinit {
        unregisterForNotifications()
    }

    //
    // MARK: - Notifications -
    //
    
    func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionAdded(_:)), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionRemoved(_:)), name: Notifications.InstitutionRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountRemoved(_:)), name: Notifications.AccountRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountExcludedFromTotal(_:)), name: Notifications.AccountExcludedFromTotal)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountIncludedInTotal(_:)), name: Notifications.AccountIncludedInTotal)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountHidden(_:)), name: Notifications.AccountHidden)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountUnhidden(_:)), name: Notifications.AccountUnhidden)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncCompleted(_:)), name: Notifications.SyncCompleted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountPatched(_:)), name: Notifications.AccountPatched)
    }
    
    func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountExcludedFromTotal)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountIncludedInTotal)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountHidden)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountUnhidden)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountPatched)
    }
    
    fileprivate let institutionUpdateDelay = 0.3
    
    // Have to do all this because tableView.updateRows equality checks don't work for Swift objects, so we need to make sure
    // that the references are equal or the animation is broken
    @objc fileprivate func institutionAdded(_ notification: Notification) {
        var reload = true
        // TODO: Animate
//        if let institutionId = notification.userInfo?[Notifications.Keys.InstitutionId] as? Int {
//            if let institution = Institution(institutionId: institutionId) {
//                let oldData = viewModel.data
//                viewModel.institutionAdded(institution: institution)
//                //updatePromptView()
//                reload = false
//                
//                // Wait for the animation to finish before sliding in the rows
//                async(after: institutionUpdateDelay) {
//                    do {
//                        try ObjC.catchException {
//                            self.tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: self.viewModel.data.flattened as NSArray, animationOptions: [.effectFade, .slideDown])
//                        }
//                    } catch {
//                        self.tableView.reloadData()
//                    }
//                    
//                    self.updateTotalBalance()
//                    
//                    // Scroll to the end of the table
//                    async(after: self.institutionUpdateDelay) {
//                        NSAnimationContext.runAnimationGroup({ context in
//                            context.allowsImplicitAnimation = true
//                            self.tableView.scrollRowToVisible(self.viewModel.data.count - 1)
//                        }, completionHandler: nil)
//                    }
//                }
//            }
//        }
        
        if reload {
            // Note: This should never happen, just a fallback
            async(after: institutionUpdateDelay) {
                self.reloadData()
            }
        }
    }
    
    // Have to do all this because tableView.updateRows equality checks don't work for Swift objects, so we need to make sure
    // that the references are equal or the animation is broken
    @objc fileprivate func institutionRemoved(_ notification: Notification) {
        var reload = true
        // TODO: Animate
//        if let institution = notification.userInfo?[Notifications.Keys.Institution] as? Institution {
//            let oldData = viewModel.data
//            viewModel.institutionRemoved(institution: institution)
//            //updatePromptView()
//            reload = false
//            
//            // Wait for the animation to finish before sliding in the rows
//            async(after: institutionUpdateDelay) {
//                do {
//                    try ObjC.catchException {
//                        self.tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: self.viewModel.data.flattened as NSArray, animationOptions: [.effectFade, .slideDown])
//                    }
//                } catch {
//                    self.tableView.reloadData()
//                }
//                
//                self.updateTotalBalance()
//                
//                // Only adjust if we're visible
//                if self.view.window != nil {
//                    self.adjustWindowHeight()
//                }
//            }
//        }
        
        if reload {
            // Note: This should never happen, just a fallback
            async(after: institutionUpdateDelay) {
                self.reloadData()
            }
        }
    }
    
    // Have to do all this because tableView.updateRows equality checks don't work for Swift objects, so we need to make sure
    // that the references are equal or the animation is broken
    @objc fileprivate func accountRemoved(_ notification: Notification) {
        var reload = true
        // TODO: Animate
//        if let account = notification.userInfo?[Notifications.Keys.Account] as? Account {
//            let oldData = viewModel.data
//            viewModel.accountRemoved(account: account)
//            updatePromptView()
//            reload = false
//            
//            do {
//                try ObjC.catchException {
//                    self.tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: viewModel.data.flattened as NSArray, animationOptions: [.effectFade, .slideDown])
//                }
//            } catch {
//                self.tableView.reloadData()
//            }
//            
//            self.updateTotalBalance()
//        }
        
        if reload {
            // Note: This should never happen, just a fallback
            async(after: institutionUpdateDelay) {
                self.reloadData()
            }
        }
    }
    
    @objc fileprivate func accountExcludedFromTotal(_ notification: Notification) {
        updateTotalBalance()
    }
    
    @objc fileprivate func accountIncludedInTotal(_ notification: Notification) {
        updateTotalBalance()
    }
    
    @objc fileprivate func accountHidden(_ notification: Notification) {
        reloadData()
    }
    
    @objc fileprivate func accountUnhidden(_ notification: Notification) {
        reloadData()
    }
    
    @objc fileprivate func syncCompleted(_ notification: Notification) {
        reloadData()
    }
    
    @objc fileprivate func accountPatched(_ notification: Notification) {
        reloadData()
    }
    
    //
    // MARK: - Data Reloading -
    //
    
    func reloadData() {
        // Load the sort order
        viewModel.reloadData()
        updateTotalBalance()
        tableView.reloadData()
        //createFixPasswordPrompt()
    }
    
    func updateTotalBalance() {
        //totalField.attributedStringValue = centsToStringFormatted(viewModel.totalBalance(), showNegative: true)
    }
    
    //
    // MARK: - Table View -
    //
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Temporary
        return viewModel.institution(forSection: section)?.name ?? "Unknown"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Temporary
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Account cell")
        let account = viewModel.account(forRow: indexPath.row, inSection: indexPath.section)
        cell.textLabel?.text = account?.displayName ?? "Unknown"
        return cell
    }
}

