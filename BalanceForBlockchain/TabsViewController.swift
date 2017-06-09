//
//  TabsViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import SnapKit

enum Tab: Int {
    case none           = -1
    case accounts       = 0
}

class TabsViewController: NSViewController {
    
    //
    // MARK: - Properties -
    //
    
    // MARK: Tabs
    let tabContainerView = View()
    let accountsViewController = AccountsTabViewController()
    var feedbackViewController: EmailIssueController?
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
        super.init(nibName: nil, bundle: nil)!
        
        self.defaultTab = defaultTab
        
        addShortcutMonitor()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        currentTableViewController?.viewWillAppear()
    }
    
    deinit {
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
        
        tabContainerView.layerBackgroundColor = NSColor.clear
        self.view.addSubview(tabContainerView)
        tabContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        
//        showTab(tabIndex: defaultTab.rawValue)
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
    
    func showSettingsMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: "Add an Account          ", action: #selector(showAddAccount), keyEquivalent: "")
        menu.items.first?.isEnabled = networkStatus.isReachable
        menu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Send Feedback", action: #selector(sendFeedback), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Balance", action: #selector(quitApp), keyEquivalent: "q")
        
        let event = NSApplication.shared().currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    func showAddAccount() {
        NotificationCenter.postOnMainThread(name: Notifications.ShowAddAccount)
    }
    
    func showPreferences() {
        AppDelegate.sharedInstance.showPreferences()
    }
    
    func sendFeedback() {
        guard let superview = self.view.superview, let currentTableViewController = currentTableViewController, feedbackViewController == nil else {
            let urlString = "mailto:support@balancemy.money?Subject=Balance%20Feedback"
            _ = try? NSWorkspace.shared().open(URL(string: urlString)!, options: [], configuration: [:])
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
    
    func quitApp() {
        NSApp.terminate(nil)
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
            shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event -> NSEvent? in
                // Specific check for preferences window when locked, otherwise the built in
                // shortcut will take over even though I disabled it in the mainMenu.xib :/
                if appLock.locked {
                    if let characters = event.charactersIgnoringModifiers {
                        if event.modifierFlags.contains(.command) && characters.length == 1 {
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
