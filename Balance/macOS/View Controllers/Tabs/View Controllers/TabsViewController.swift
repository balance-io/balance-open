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
    case feed           = 2
    case insights       = 3
}

class TabsViewController: NSViewController {
    
    //
    // MARK: - Properties -
    //
    
    // MARK: Header
    let headerBackgroundView = HeaderBackgroundView()
    let headerView = View()
    var accountsButton: TabButton!
    var transactionsButton: TabButton!
    var feedButton: TabButton!
    var insightsButton: TabButton!
    var tabButtons = [TabButton]()
    
    // MARK: Tabs
    let tabContainerView = View()
    let accountsViewController = AccountsTabViewController()
    let transactionsViewController = TransactionsTabViewController()
    let notificationsViewController = NotificationsTabViewController()
    let insightsViewController = InsightsTabViewController()
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
    let syncButton = SyncButton()
    let preferencesButton = Button()
    
    //
    // MARK: - Lifecycle -
    //
    
    init(defaultTab: Tab = Tab.accounts) {
        super.init(nibName: nil, bundle: nil)
        
        self.defaultTab = defaultTab
        
        let inactive = CurrentTheme.tabs.header.tabIconColorInactive
        let border = CurrentTheme.tabs.header.tabIconBorderColor
        let active = CurrentTheme.tabs.header.tabIconColorActive
        
        let accountsTabIcon = AccountsTabIcon(tabIconColor: inactive, tabIconBorderColor: border, tabIconSelectedColor: active)
        let transactionsTabIcon = TransactionsTabIcon(tabIconColor: inactive, tabIconBorderColor: border, tabIconSelectedColor: active)
        let feedTabIcon = FeedTabIcon(tabIconColor: inactive, tabIconBorderColor: border, tabIconSelectedColor: active)
        let feedAltTabIcon = FeedTabIcon(tabIconColor: inactive, tabIconBorderColor: border, tabIconSelectedColor: active)
        let insightsTabIcon = InsightsTabIcon(tabIconColor: inactive, tabIconBorderColor: border, tabIconSelectedColor: active)
        
        accountsButton = TabButton(iconView: accountsTabIcon, labelText: "Accounts")
        transactionsButton = TabButton(iconView: transactionsTabIcon, labelText: "Transactions")
        feedButton = TabButton(iconView: feedTabIcon, altIconView: feedAltTabIcon, labelText: "Notifications")
        insightsButton = TabButton(iconView: insightsTabIcon, labelText: "Insights")
        tabButtons = [accountsButton, transactionsButton, feedButton, insightsButton]
        
        var i = 0
        for tabButton in tabButtons {
            tabButton.button.target = self
            tabButton.button.action = #selector(tabAction(_:))
            tabButton.button.tag = i
            i += 1
        }
        
        tabControllers = [accountsViewController, transactionsViewController, notificationsViewController, insightsViewController]
        
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
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(footerView.snp.top)
        }
        
        if debugging.defaultToInsightsTab {
            showTab(tabIndex: Tab.insights.rawValue)
        } else if debugging.defaultToTransactionsTab {
            showTab(tabIndex: Tab.transactions.rawValue)
        } else {
            showTab(tabIndex: defaultTab.rawValue)
        }
        
        if !debugging.disableTransactions {
            // Preload the transaction views
            let _ = transactionsViewController.view
            let _ = notificationsViewController.view
            let _ = insightsViewController.view
        }
    }
    
    func createHeader() {
        if debugging.disableTransactions {
            // Header container
            headerBackgroundView.frame = NSRect(x: 0, y: 0, width: 400, height: 0)
            headerBackgroundView.layer?.backgroundColor = NSColor.red.cgColor
            self.view.addSubview(headerBackgroundView)
            headerBackgroundView.snp.makeConstraints { make in
                make.width.equalTo(400)
                make.height.equalTo(0)
                make.centerX.equalTo(self.view).offset(0)
                make.top.equalTo(self.view)
            }
            
            self.view.addSubview(headerView)
            headerView.snp.makeConstraints { make in
                make.width.equalTo(308)
                make.height.equalTo(0)
                make.centerX.equalTo(self.view).offset(1)
                make.top.equalTo(self.view)
            }
        } else {
            // Header container
            headerBackgroundView.frame = NSRect(x: 0, y: 0, width: 400, height: 45)
            headerBackgroundView.layer?.backgroundColor = NSColor.red.cgColor
            self.view.addSubview(headerBackgroundView)
            headerBackgroundView.snp.makeConstraints { make in
                make.width.equalTo(400)
                make.height.equalTo(45)
                make.centerX.equalTo(self.view).offset(0)
                make.top.equalTo(self.view)
            }
            
            self.view.addSubview(headerView)
            headerView.snp.makeConstraints { make in
                make.width.equalTo(308)
                make.height.equalTo(45)
                make.centerX.equalTo(self.view).offset(1)
                make.top.equalTo(self.view)
            }
            
            // Accounts button
            headerView.addSubview(accountsButton)
            accountsButton.snp.makeConstraints { make in
                make.centerX.equalTo(headerView).multipliedBy(0.245)
                make.top.equalTo(headerView).offset(5)
            }
            
            // Transactions button
            headerView.addSubview(transactionsButton)
            transactionsButton.snp.makeConstraints { make in
                make.centerX.equalTo(headerView).multipliedBy(0.735)
                make.top.equalTo(headerView).offset(5)
            }
            
            // Feed button
            headerView.addSubview(feedButton)
            feedButton.snp.makeConstraints { make in
                make.centerX.equalTo(headerView).multipliedBy(1.285)
                make.top.equalTo(headerView).offset(5)
            }
            
            // Insights button
            headerView.addSubview(insightsButton)
            insightsButton.snp.makeConstraints { make in
                make.centerX.equalTo(headerView).multipliedBy(1.76)
                make.top.equalTo(headerView).offset(5)
            }
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
        
        // Sync button
        footerView.addSubview(syncButton)
        syncButton.snp.makeConstraints { make in
            make.leading.equalTo(footerView).offset(8)
            make.centerY.equalTo(footerView)
            make.width.equalTo(350)
            make.height.equalTo(footerView)
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
//        // Prepare preferences button for spin animation
//        // Adapted from: https://github.com/bansalvks/Mac-Dummies/blob/master/Rotate%20NSImageView/animationTrial/AppDelegate.m
//        if spinAnimation == nil {
//            if let layer = self.preferencesButton.layer {
//                layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//                let frame = layer.frame
//                let x = frame.origin.x + frame.size.width
//                let y = frame.origin.y + frame.size.height
//                layer.position = CGPoint(x: x, y: y)
//                layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//            }
//            
//            let spin = CABasicAnimation(keyPath: "transform.rotation")
//            spin.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//            spin.fromValue = NSNumber(value: 0 as Float)
//            spin.toValue = NSNumber(value: 180 as Float)
//            spin.duration = 1
//            spinAnimation = spin
//        }
//        
//        preferencesButton.layer?.add(spinAnimation!, forKey: "transform")
        
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
    
    func showFeedTab() {
        tabAction(tabButtons[Tab.feed.rawValue].button)
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    func updateFeedIcon() {
        let unreadCount = defaults.unreadNotificationIds.count
        let feedButton = tabButtons[Tab.feed.rawValue]
        feedButton.altBehavior = unreadCount > 0
    }
    
    func showTab(tabIndex: Int) {
        guard currentVisibleTab.rawValue != tabIndex && feedbackViewController == nil else {
            return
        }
        
        // Analytics
        var contentName = ""
        switch tabIndex {
        case 0: contentName = "Accounts tab selected"
        case 1: contentName = "Transactions tab selected"
        case 2: contentName = "Feed tab selected"
        case 3: contentName = "Insights tab selected"
        default: break
        }
//        Answers.logContentView(withName: contentName, contentType: nil, contentId: nil, customAttributes: nil)
        
        for i in 0...tabButtons.count-1 {
            let tabButton = tabButtons[i]
            if i == tabIndex {
                tabButton.activate()
            } else {
                tabButton.deactivate()
            }
        }
        
        // TODO: Move this into the NotificationsTabViewController
        // Clear notifications if needed
        if currentVisibleTab == .feed {
            defaults.unreadNotificationIds = Set<Int>()
            updateFeedIcon()
            notificationsViewController.reloadData()
        }
        
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
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncCompleted), name: Notifications.SyncCompleted)
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.PerformSearch)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowSearch)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowTabIndex)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
    }

    @objc fileprivate func performSearch(_ notification: Notification) {
        if let searchString = notification.userInfo?[Notifications.Keys.SearchString] as? String {
            if currentVisibleTab != .transactions {
                tabAction(transactionsButton.button)
            }
            transactionsViewController.performSearch(searchString)
        }
    }
    
    @objc fileprivate func showSearch(_ notification: Notification) {
        if currentVisibleTab != .transactions {
            tabAction(transactionsButton.button)
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
    
    @objc fileprivate func syncCompleted() {
        updateFeedIcon()
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
                            if let intValue = Int(characters), intValue > 0 && intValue <= self.tabButtons.count {
                                // Select tab
                                self.tabAction(self.tabButtons[intValue - 1].button)
                                return nil
                            } else if characters == "," {
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
