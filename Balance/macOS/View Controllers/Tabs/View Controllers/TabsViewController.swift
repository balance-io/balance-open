//
//  TabsViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import SnapKit
import BalanceVectorGraphics

enum Tab: Int {
    case none           = -1
    case accounts       = 0
    case transactions   = 1
}

class TabsViewController: NSViewController {
    
    //
    // MARK: - Properties -
    //
    
    // MARK: Header
    let headerView = View()
    let accountsButton = Button()
    let transactionsButton = Button()
    
    // MARK: Tabs
    let tabContainerView = View()
    let accountsViewController = AccountsTabViewController()
    let transactionsViewController = TransactionsTabViewController()
    var feedbackViewController: EmailIssueController?
    var tabControllers = [NSViewController]()
    let tabSwitchDelay = 1.0
    let summaryFooterView = View()
    var currentTableViewController: NSViewController?
    var currentVisibleTab = Tab.none
    var defaultTab = Tab.accounts
    
    // MARK: Footer
    let footerView = View()
    let refreshButton = Button()
    let preferencesButton = Button()
    
    //
    // MARK: - Lifecycle -
    //
    
    init(defaultTab: Tab = Tab.accounts) {
        super.init(nibName: nil, bundle: nil)
        
        self.defaultTab = defaultTab
        
        tabControllers = [accountsViewController, transactionsViewController]
        
        registerForNotifications()
        addShortcutMonitor()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        currentTableViewController?.viewWillAppear()
    }
    
    deinit {
        unregisterForNotifications()
        removeShortcutMonitor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }

    //
    // MARK: - View Creation -
    //
    
    override func loadView() {
        self.view = View()
        
        // Create the UI
        createFooter()
        createHeader()
        
        tabContainerView.layerBackgroundColor = NSColor.clear
        self.view.addSubview(tabContainerView)
        tabContainerView.snp.makeConstraints { make in
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.bottom.equalTo(footerView.snp.top)
        }
        
        if debugging.defaultToTransactionsTab {
            showTab(tabIndex: Tab.transactions.rawValue)
        } else {
            showTab(tabIndex: defaultTab.rawValue)
        }
        
        // Preload the transaction views
        let _ = transactionsViewController.view
    }
    
    func createHeader() {
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        accountsButton.target = self
        accountsButton.action = #selector(tabAction(_:))
        accountsButton.tag = Tab.accounts.rawValue
        accountsButton.image = #imageLiteral(resourceName: "TabIconAccountsInactive")
        //accountsButton.alternateImage = #imageLiteral(resourceName: "TabIconAccountsActive")
        accountsButton.title = "Accounts"
        //accountsButton.titleColor = CurrentTheme.tabs.header.tabFontColor
        accountsButton.font = CurrentTheme.tabs.header.tabFont
        accountsButton.setAccessibilityLabel("Accounts")
        //accountsButton.setButtonType(.momentaryPushIn)
        accountsButton.imagePosition = .imageLeft
        accountsButton.isBordered = false
        accountsButton.sizeToFit()
        headerView.addSubview(accountsButton)
        accountsButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        transactionsButton.target = self
        transactionsButton.action = #selector(tabAction(_:))
        transactionsButton.tag = Tab.transactions.rawValue
        transactionsButton.image = #imageLiteral(resourceName: "TabIconTransactionsInactive")
        transactionsButton.alternateImage = #imageLiteral(resourceName: "TabIconTransactionsActive")
        transactionsButton.title = "Transactions"
        //transactionsButton.bezelStyle = .rounded
        transactionsButton.setAccessibilityLabel("Transactions")
        transactionsButton.sizeToFit()
        headerView.addSubview(transactionsButton)
        transactionsButton.snp.makeConstraints { make in
            make.left.equalTo(accountsButton.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func createFooter() {
        // Footer container
        footerView.layerBackgroundColor = CurrentTheme.tabs.footer.backgroundColor
        self.view.addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.width.equalTo(self.view)
            make.height.equalTo(38)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        // Preferences button
        preferencesButton.target = self
        preferencesButton.action = #selector(showSettingsMenu(_:))
        let preferencesIcon = CurrentTheme.tabs.footer.preferencesIcon
        preferencesButton.image = preferencesIcon
        preferencesButton.setButtonType(.momentaryChange)
        preferencesButton.setAccessibilityLabel("Preferences")
        preferencesButton.isBordered = false
        footerView.addSubview(preferencesButton)
        preferencesButton.snp.makeConstraints { make in
            make.centerY.equalTo(footerView)
            make.trailing.equalTo(footerView).offset(-10)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
    }
    
    //
    // MARK: - Actions -
    //
    
    var spinAnimation: CABasicAnimation?
    
    @objc func showSettingsMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: "Add an Account          ", action: #selector(showAddAccount), keyEquivalent: "")
        menu.items.first?.isEnabled = networkStatus.isReachable
        menu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Send Feedback", action: #selector(sendFeedback), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Balance", action: #selector(quitApp), keyEquivalent: "q")
        
        let event = NSApplication.shared.currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    @objc func showAddAccount() {
        NotificationCenter.postOnMainThread(name: Notifications.ShowAddAccount)
    }
    
    @objc func showPreferences() {
        AppDelegate.sharedInstance.showPreferences()
    }
    
    @objc func sendFeedback() {
        guard let superview = self.view.superview, let currentTableViewController = currentTableViewController, feedbackViewController == nil else {
            let urlString = "mailto:support@balancemy.money?Subject=Balance%20Feedback"
            _ = try? NSWorkspace.shared.open(URL(string: urlString)!, options: [], configuration: [:])
            return
        }
            
        feedbackViewController = EmailIssueController {
            currentTableViewController.viewWillAppear()
            self.feedbackViewController!.viewWillDisappear()
            superview.replaceSubview(self.feedbackViewController!.view, with: self.view, animation: .slideInFromLeft) {
                currentTableViewController.viewDidAppear()
                self.feedbackViewController!.viewDidDisappear()
                self.feedbackViewController = nil
            }
        }
        
        currentTableViewController.viewWillDisappear()
        feedbackViewController!.viewWillAppear()
        superview.replaceSubview(self.view, with: feedbackViewController!.view, animation: .slideInFromRight) {
            self.feedbackViewController!.viewDidAppear()
            currentTableViewController.viewDidDisappear()
        }
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    func showTab(tabIndex: Int) {
        guard currentVisibleTab.rawValue != tabIndex && feedbackViewController == nil else {
            return
        }
        
        // Analytics
        var contentName = ""
        switch tabIndex {
        case Tab.accounts.rawValue:     contentName = "Accounts tab selected"
        case Tab.transactions.rawValue: contentName = "Transactions tab selected"
        default: break
        }
        BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: contentName)
        
//        for i in 0...tabButtons.count-1 {
//            let tabButton = tabButtons[i]
//            if i == tabIndex {
//                tabButton.activate()
//            } else {
//                tabButton.deactivate()
//            }
//        }
        
        // Constraints
        let constraints: (ConstraintMaker) -> Void = { make in
            make.leading.equalTo(self.tabContainerView)
            make.trailing.equalTo(self.tabContainerView)
            make.top.equalTo(self.tabContainerView)
            make.bottom.equalTo(self.tabContainerView)
        }
        
        let controller = tabControllers[tabIndex]
        
        // Fade between tabs
        if let currentTableViewController = currentTableViewController {
            currentTableViewController.viewWillDisappear()
            controller.viewWillAppear()
            tabContainerView.replaceSubview(currentTableViewController.view, with: controller.view, animation: .none, duration: 0, constraints: constraints) {
                controller.viewDidAppear()
                currentTableViewController.viewDidDisappear()
            }
        } else {
            controller.viewWillAppear()
            tabContainerView.addSubview(controller.view)
            controller.view.snp.makeConstraints(constraints)
            controller.viewDidAppear()
        }
        
        currentTableViewController = controller
        currentVisibleTab = Tab(rawValue: tabIndex)!
        self.view.window?.makeFirstResponder(currentTableViewController)
    }
    
    @objc fileprivate func tabAction(_ sender: Button) {
        showTab(tabIndex: sender.tag)
    }
    
    //
    // MARK: - Notifications -
    //
    
    fileprivate func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(performSearch(_:)), name: Notifications.PerformSearch)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showSearch(_:)), name: Notifications.ShowSearch)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showTabIndex(_:)), name: Notifications.ShowTabIndex)
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.PerformSearch)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowSearch)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowTabIndex)
    }

    @objc fileprivate func performSearch(_ notification: Notification) {
        if let searchString = notification.userInfo?[Notifications.Keys.SearchString] as? String {
            if currentVisibleTab != .transactions {
//                tabAction(transactionsButton.button)
            }
            transactionsViewController.performSearch(searchString)
        }
    }
    
    @objc fileprivate func showSearch(_ notification: Notification) {
        if currentVisibleTab != .transactions {
//            tabAction(transactionsButton.button)
        }
        
        async(after: 0.25) {
            self.transactionsViewController.showSearch()
        }
    }
    
    @objc fileprivate func showTabIndex(_ notification: Notification) {
        if let tabIndex = notification.userInfo?[Notifications.Keys.TabIndex] as? Int {
            showTab(tabIndex: tabIndex)
        }
    }
    
    //
    // MARK: - Keyboard Shortcuts -
    //
    
    fileprivate var shortcutMonitor: Any?
    
    // Command + [1 - 4] to select tabs
    //
    // Command + , to open preferences
    // NOTE: This is needed because there is some hook for this installed automatically and it's incorrectly opening the preferences window
    //
    // Command + R to reload
    //
    func addShortcutMonitor() {
        if shortcutMonitor == nil {
            shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { event -> NSEvent? in
                // Specific check for preferences window when locked, otherwise the built in
                // shortcut will take over even though I disabled it in the mainMenu.xib :/
                if appLock.locked {
                    if let characters = event.charactersIgnoringModifiers {
                        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) && characters.length == 1 {
                            if characters == "," {
                                // Return nil to eat the event
                                return nil
                            } else if characters == "h" {
                                NotificationCenter.postOnMainThread(name: Notifications.HidePopover)
                                return nil
                            }
                        }
                    }
                }
                
                if !appLock.locked && event.window == self.view.window {
                    if let characters = event.charactersIgnoringModifiers {
                        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) && characters.length == 1 {
//                            if let intValue = Int(characters), intValue > 0 && intValue <= self.tabButtons.count {
//                                // Select tab
//                                self.tabAction(self.tabButtons[intValue - 1].button)
//                                return nil
//                            } else if characters == "," {
                            if characters == "," {
                                // Show Preferences
                                self.showPreferences()
                                return nil
                            } else if characters == "r" {
                                // Reload
                                syncManager.sync()
                                return nil
                            } else if characters == "h" {
                                NotificationCenter.postOnMainThread(name: Notifications.HidePopover)
                            }
                        }
                    }
                }
                
                return event
            }
        }
    }
    
    func removeShortcutMonitor() {
        if let monitor = shortcutMonitor {
            NSEvent.removeMonitor(monitor)
            shortcutMonitor = nil
        }
    }
}
