//
//  PopoverViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

enum ContentControllerType {
    case none
    case addAccount
    case patchAccount
    case tabs
    case intro
}

class PopoverViewController: NSViewController {
    
    //
    // MARK: - Properties -
    //

    fileprivate(set) var currentControllerType: ContentControllerType = .none
    fileprivate var currentController: NSViewController!
    fileprivate var tabsController = TabsViewController()
    fileprivate var lockController = LockViewController()
    fileprivate var patchController: WebSignUpViewController?
    
    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)

        registerForNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    //
    // MARK: - Create View -
    //
    
    override func loadView() {
        self.view = View()
        
        let height = debugging.showIntroOnLaunch ? 400 : 650
        self.view.frame = CGRect(x: 0, y: 0, width: 400, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preload controller views
        _ = tabsController.view
        _ = lockController.view
        
        if debugging.showAddAccountsOnLaunch {
            currentControllerType = .addAccount
            currentController = AddAccountViewController()
        } else if debugging.showIntroOnLaunch {
            currentControllerType = .intro
            currentController = IntroViewController(closeBlock: closeIntro)
        } else {
            if debugging.disableSubscription {
                if InstitutionRepository.si.hasInstitutions {
                    currentControllerType = .tabs
                    currentController = tabsController
                    if appLock.lockEnabled {
                        appLock.locked = true
                    }
                } else {
                    currentControllerType = .addAccount
                    currentController = OpenAddAccountViewController()
                }
            } else {
                if subscriptionManager.productId == .none {
                    currentControllerType = .intro
                    currentController = IntroViewController(closeBlock: closeIntro)
                } else {
                    if subscriptionManager.remainingAccounts < subscriptionManager.maxAccounts || InstitutionRepository.si.hasInstitutions {
                        currentControllerType = .tabs
                        currentController = tabsController
                        if appLock.lockEnabled {
                            appLock.locked = true
                        }
                    } else {
                        currentControllerType = .addAccount
                        currentController = AddAccountViewController()
                    }
                }
            }
        }
        
        let currentControllerView = appLock.locked ? lockController.view : currentController?.view
        if let currentControllerView = currentControllerView {
            self.view.addSubview(currentControllerView)
            currentControllerView.snp.makeConstraints { make in
                make.leading.equalTo(self.view)
                make.trailing.equalTo(self.view)
                make.top.equalTo(self.view)
                make.bottom.equalTo(self.view)
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Set the correct Dark/Light appearance
        self.view.window?.appearance = CurrentTheme.defaults.appearance
        
        NotificationCenter.postOnMainThread(name: Notifications.PopoverWillShow)
        
        if appLock.locked {
            lockController.willDisplayPopover()
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NotificationCenter.postOnMainThread(name: Notifications.PopoverWillHide)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        if appLock.lockEnabled && appLock.lockOnPopoverClose {
            lockUserInterface(animated: false)
        }
    }
    
    func showAddAccount(animated: Bool) {
        let oldController = appLock.locked ? lockController : currentController
        if currentControllerType != .addAccount, let oldController = oldController {
            currentControllerType = .addAccount
            currentController = debugging.disableSubscription ? OpenAddAccountViewController() : AddAccountViewController()
            let animation: ViewAnimation = animated ? .slideInFromRight : .none
            self.view.replaceSubview(oldController.view, with: currentController!.view, animation: animation)
        }
    }
    
    func showPatchAccount(institution: Institution, animated: Bool) {
        let oldController = appLock.locked ? lockController : currentController
        if currentControllerType != .patchAccount, let oldController = oldController {
            if patchController == nil {
                patchController = WebSignUpViewController(source: institution.source, sourceInstitutionId: institution.sourceInstitutionId, patch: true, institution: institution) { _ in
                    self.showTabs(animated: true)
                    self.patchController = nil
                }
            }
            
            if let patchController = patchController {
                currentControllerType = .patchAccount
                currentController = patchController
                let animation: ViewAnimation = animated ? .slideInFromRight : .none
                self.view.replaceSubview(oldController.view, with: currentController!.view, animation: animation)
            }
        }
    }
    
    func showTabs(animated: Bool) {
        if currentControllerType != .tabs, let oldController = currentController {
            currentControllerType = .tabs
            currentController = tabsController
            let animation: ViewAnimation = animated ? .slideInFromLeft : .none
            self.view.replaceSubview(oldController.view, with: currentController!.view, animation: animation)
            
            self.view.window?.makeFirstResponder(tabsController.currentTableViewController)
        }
    }
    
    // Reload all view controllers to use new theme
    @objc func reloadPopoverController() {
        self.view.window?.appearance = CurrentTheme.defaults.appearance
        AppDelegate.sharedInstance.statusItem.windowConfiguration.backgroundColor = CurrentTheme.defaults.backgroundColor
        AppDelegate.sharedInstance.statusItem.drawBorder = CurrentTheme.type == .light
        
        // Remember the selected tab
        let selectedTab = tabsController.currentVisibleTab
        
        if let currentControllerView = currentController?.view {
            currentControllerView.removeFromSuperview()
        }
        currentController = nil
        lockController = LockViewController()
        tabsController = TabsViewController(defaultTab: selectedTab)
        
        if currentControllerType == .patchAccount {
            currentControllerType = .tabs
        }
        
        if currentControllerType == .tabs {
            currentController = tabsController
        } else if currentControllerType == .addAccount {
            currentController = debugging.disableSubscription ? OpenAddAccountViewController() : AddAccountViewController()
        } else if currentControllerType == .intro {
            currentController = IntroViewController(closeBlock: closeIntro)
        }
        
        if appLock.locked {
            self.view.addSubview(lockController.view)
            lockController.view.snp.makeConstraints { make in
                make.leading.equalTo(self.view)
                make.trailing.equalTo(self.view)
                make.width.equalTo(self.view)
                make.height.equalTo(self.view)
            }
        } else {
            if let currentControllerView = currentController?.view {
                self.view.addSubview(currentControllerView)
                currentControllerView.snp.makeConstraints { make in
                    make.leading.equalTo(self.view)
                    make.trailing.equalTo(self.view)
                    make.width.equalTo(self.view)
                    make.height.equalTo(self.view)
                }
            }
        }
    }
    
    func lockUserInterface(animated: Bool) {
        if !appLock.locked {
            appLock.locked = true
            let animation: ViewAnimation = animated ? .fade : .none
            lockController.viewWillAppear()
            currentController.viewWillDisappear()
            self.view.replaceSubview(currentController.view, with: lockController.view, animation: animation)
            lockController.viewDidAppear()
            currentController.viewDidDisappear()
            
            AppDelegate.sharedInstance.preferencesWindowController.close()
        }
    }
    
    func unlockUserInterface(animated: Bool, delayViewAppearCalls: Bool = false) {
        if appLock.locked {
            appLock.locked = false
            
            let animation: ViewAnimation = animated ? .fade : .none
            lockController.viewWillDisappear()
            if !delayViewAppearCalls {
                currentController.viewWillAppear()
            }
            self.view.replaceSubview(lockController.view, with: currentController.view, animation: animation)
            lockController.viewDidDisappear()
            if !delayViewAppearCalls {
                currentController.viewDidAppear()
            }
            
            if delayViewAppearCalls {
                async(after: 0.1) {
                    self.currentController.viewWillAppear()
                    self.currentController.viewDidAppear()
                }
            }
            
            // Fix for touch bar
            if currentControllerType == .tabs {
                self.view.window?.makeFirstResponder(tabsController.currentTableViewController)
            } else {
                self.view.window?.makeFirstResponder(currentController)
            }
        }
    }

    //
    // MARK: Notifications
    //
    
    fileprivate func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionAdded), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionRemoved), name: Notifications.InstitutionRemoved)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showAddAccountNotification), name: Notifications.ShowAddAccount)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showTabsNotification), name: Notifications.ShowTabs)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadPopoverController), name: Notifications.ReloadPopoverController)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showIntro), name: Notifications.ShowIntro)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showPatchAccount(notification:)), name: Notifications.ShowPatchAccount)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(lockUserInterfaceNotification), name: Notifications.LockUserInterface)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(unlockUserInterfaceNotification), name: Notifications.UnlockUserInterface)
        
        DistributedNotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadPopoverController), name: Notification.Name("AppleInterfaceThemeChangedNotification"))
        
        // App locking
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(screenDidSleep), name: NSWorkspace.screensDidSleepNotification, object: nil)
        DistributedNotificationCenter.addObserverOnMainThread(self, selector: #selector(screenDidLock), name: Notification.Name("com.apple.screensaver.didstart"))
        DistributedNotificationCenter.addObserverOnMainThread(self, selector: #selector(screenDidLock), name: Notification.Name("com.apple.screenIsLocked"))
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowAddAccount)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowTabs)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ReloadPopoverController)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowIntro)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowPatchAccount)
        
        DistributedNotificationCenter.removeObserverOnMainThread(self, name: Notification.Name("AppleInterfaceThemeChangedNotification"))
        
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.screensDidSleepNotification, object: nil)
        DistributedNotificationCenter.removeObserverOnMainThread(self, name: Notification.Name("com.apple.screensaver.didstart"))
        DistributedNotificationCenter.removeObserverOnMainThread(self, name: Notification.Name("com.apple.screenIsLocked"))
    }
    
    @objc fileprivate func institutionAdded() {
        showTabs(animated: true)
    }
    
    @objc fileprivate func institutionRemoved() {
        if !InstitutionRepository.si.hasInstitutions && subscriptionManager.productId != .none {
            AppDelegate.sharedInstance.preferencesWindowController.close()
            showAddAccount(animated: true)
        }
    }
    
    @objc fileprivate func showAddAccountNotification() {
        showAddAccount(animated: true)
    }
    
    @objc fileprivate func showTabsNotification() {
        showTabs(animated: true)
    }
    
    @objc fileprivate func appleInterfaceThemeChanged() {
        // Do nothing for now as we only use one theme
    }
    
    @objc fileprivate func showIntro() {
        if currentControllerType != .intro, let oldController = currentController {
            appLock.lockEnabled = false
            currentControllerType = .intro
            currentController = IntroViewController(closeBlock: closeIntro)
            self.view.replaceSubview(oldController.view, with: currentController!.view, animation: .slideInFromLeft)
        }
    }
    
    @objc fileprivate func showPatchAccount(notification: Notification) {
        if let userInfo = notification.userInfo, let institution = userInfo[Notifications.Keys.Institution] as? Institution {
            showPatchAccount(institution: institution, animated: true)
        }
    }
    
    @objc fileprivate func lockUserInterfaceNotification() {
        lockUserInterface(animated: true)
    }
    
    @objc fileprivate func unlockUserInterfaceNotification() {
        unlockUserInterface(animated: true)
    }
    
    @objc fileprivate func screenDidLock() {
        if appLock.lockEnabled && appLock.lockOnSleep {
            lockUserInterface(animated: false)
        }
    }
    
    @objc fileprivate func screenDidSleep() {
        if appLock.lockEnabled && appLock.lockOnScreenSaver {
            lockUserInterface(animated: false)
        }
    }
    
    fileprivate func closeIntro() {
        showAddAccount(animated: true)
    }
}
