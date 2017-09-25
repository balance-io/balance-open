//
//  TransactionContextMenu.swift
//  Bal
//
//  Created by Benjamin Baron on 10/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class TransactionContextMenu: NSObject, NSMenuDelegate {
    fileprivate let transaction: Transaction
    fileprivate let gmailSearchDateFormatter = DateFormatter()
    fileprivate var selfRef: TransactionContextMenu?
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init()
        
        self.gmailSearchDateFormatter.dateFormat = "YYYY/M/d"
        
        // Keep a circular reference to prevent deallocation until menu is completed
        self.selfRef = self
    }
    
    static func showMenu(transaction: Transaction, view: NSView) {
        var items = [NSMenuItem(title: "Find Similar Transactions", action: #selector(searchTransactionsAction), keyEquivalent: ""),
                     NSMenuItem.separator(),
                     NSMenuItem(title: "Copy Transaction", action: #selector(copyTransactionToClipboard), keyEquivalent: ""),
                     NSMenuItem(title: "Copy Merchant Name", action: #selector(copyNameToClipboard), keyEquivalent: ""),
                     NSMenuItem(title: "Copy Amount", action: #selector(copyAmountToClipboard), keyEquivalent: "")]
        
        #if DEBUG
        items.append(NSMenuItem.separator())
        items.append(NSMenuItem(title: "Log transaction id", action: #selector(logTransactionId), keyEquivalent: ""))
        #endif
        
        let contextMenu = TransactionContextMenu(transaction: transaction)
        let menu = NSMenu()
        menu.delegate = contextMenu
        for item in items {
            item.target = contextMenu
            menu.addItem(item)
        }
        
        let event = NSApplication.shared.currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: view)
    }
    
    @objc fileprivate func searchTransactionsAction() {
        let name = transaction.displayName
        NotificationCenter.postOnMainThread(name: Notifications.PerformSearch, object: nil, userInfo: [Notifications.Keys.SearchString: name])
        
        // Analytics
//        Answers.logContentView(withName: "Accounts tab cell transactions searched", contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    @objc fileprivate func copyTransactionToClipboard() {
        let name = transaction.displayName
        let amount = centsToStringFormatted(transaction.amount).string
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("\(name) \(amount)", forType: NSPasteboard.PasteboardType.string)
    }
    
    @objc fileprivate func copyNameToClipboard() {
        let name = transaction.displayName
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(name, forType: NSPasteboard.PasteboardType.string)
    }
    
    @objc fileprivate func copyAmountToClipboard() {
        let amount = centsToStringFormatted(transaction.amount).string
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(amount, forType: NSPasteboard.PasteboardType.string)
    }

    func menuDidClose(_ menu: NSMenu) {
        // Bit of a hack to ensure no bad memory accesses. This delegate method is called before the 
        // menu item action. While it appears to be called in the same runloop (thus ensuring no deallocation
        // between this call and the action), who knows if that will change. So instead we ensure deallocation
        // happens on a later runloop iteration.
        DispatchQueue.userInitiated.async(after: 1.0) {
            // Menu is closed so allow deallocation
            self.selfRef = nil
        }
    }
    
    /*
     * Debugging
     */
    
    @objc fileprivate func logTransactionId() {
        print("transactionId: \(transaction.transactionId)  sourceTransactionId: \(transaction.sourceTransactionId)")
    }
}
