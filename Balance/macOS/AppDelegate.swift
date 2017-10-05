import Cocoa
import Locksmith
import ServiceManagement
import RealmSwift

let autolaunchBundleId = "software.balanced.balance-open-autolaunch"

class AppDelegate: NSObject, NSApplicationDelegate {
    
    //
    // MARK: - Properties -
    //
    
    static fileprivate(set) var sharedInstance: AppDelegate!
    
    let statusItem = CCNStatusItem.sharedInstance()!
    var contentViewController: PopoverViewController!
    var preferencesWindowController: NSWindowController!
    
    var launchedAtLogin = false
    var isAutolaunchHelperRunning: Bool {
        let appsRunning = NSRunningApplication.runningApplications(withBundleIdentifier: autolaunchBundleId)
        return appsRunning.count > 0
    }
    
    var pinned: Bool {
        get {
            return statusItem.windowConfiguration.isPinned
        }
        set {
            statusItem.windowConfiguration.isPinned = newValue
        }
    }
    
    var maxHeight: CGFloat {
        if let screen = contentViewController.view.window?.screen {
            if screen.frame.size.height <= 850 {
                return CurrentTheme.defaults.size.height
            } else {
                return CurrentTheme.defaults.size.height + 100
            }
        }
        return CurrentTheme.defaults.size.height
    }
    
    // For debugging
    let showInWindow = false
    let window = NSWindow()
    
    //
    // MARK: - Lifecycle -
    //
    
    override init() {
        super.init()
        
        terminateIfAlreadyRunning()
        
        // Swizzle all needed methods (can't use class initialize anymore since Swift 3.1)
        swizzleMethods()
        
        // Create a singleton reference
        AppDelegate.sharedInstance = self

        if (debugging.useMockSession) {
            URLProtocol.registerClass(PlaidDataMockingProtocol.self)
        }
        
        registerForNotifications()
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    // Based on information from this answer http://stackoverflow.com/a/3770735/299262 and it's comments
    func terminateIfAlreadyRunning() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            // Look for instances of Balance
            let applications = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            for application in applications {
                // If any instances are not this one, terminate
                if application != NSRunningApplication.current {
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
    fileprivate func hockeyAppInit() {
        #if !DEBUG
            BITHockeyManager.shared().configure(withIdentifier: "bca73ad39bdb4dda98870be89899e263")
            BITHockeyManager.shared().start()
        #endif
    }
    
    fileprivate func storeInit() {
        subscriptionManager.updatePrices()
        subscriptionManager.completeTransactions()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Make sure we're running from the Application folder or updates won't work
        #if !DEBUG
            PFMoveToApplicationsFolderIfNecessary()
        #endif
        
        #if !DEBUG
            // Check for existance of receipt data and exit with status code 173 if missing to refresh the receipt (App Store requirement)
            if !betaOptionsEnabled && !debugging.disableSubscription && subscriptionManager.receiptData == nil {
                exit(173)
            }
        #endif
        
        // Register our app to get notified when launched via URL
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(AppDelegate.handleURLEvent(event:withReply:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL)
        )
        
        // Check for the helper app to see if we were auto launched
        launchedAtLogin = isAutolaunchHelperRunning
        
        // Setup Realm options
//        RealmSwift.SyncManager.shared.logLevel = SyncLogLevel.all
//        RealmSwift.SyncManager.shared.errorHandler = { error, _ in
//            print("Realm error: \(error)")
//        }
        
        // Initialize singletons
        initializeSingletons()
        
        // Initialize logging
        logging.setupLogging()
        
        // Initialize UserDefaults
        defaults.setupDefaults()
        //defaults.setupCloudSyncing()
        
        // Initialize local notifications delegate
        NSUserNotificationCenter.default.delegate = self
        
        // Initialyze crash logging and analytics
        hockeyAppInit()
        
        if !debugging.disableSubscription {
            // Initialize Store
            storeInit()
        }
        
        // Initialize database
        database.create()
        
        // Access tokens and Realm syncing credentials for debugging
        #if DEBUG
            if !Testing.runningUiTests {
                if debugging.logAccessTokens {
                    for institution in InstitutionRepository.si.allInstitutions() {
                        if let accessToken = institution.accessToken {
                            log.debug("(\(institution)): accessToken: \(accessToken)")
                            if let refreshToken = institution.refreshToken {
                                log.debug("(\(institution)): refreshToken: \(refreshToken)")
                            }
                        }
                    }
                }
                if debugging.logRealmCredentials {
                    log.debug("realmUser: \(String(describing: subscriptionManager.realmUser))")
                    log.debug("realmPass: \(String(describing: subscriptionManager.realmPass))")
                }
            }
        #endif
        
        // Start monitoring network status
        networkStatus.startMonitoring()
        
        // Setup shortcut
        Shortcut.setupDefaultShortcut()
        
        // Prepare the preferences window
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        self.preferencesWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "preferencesWindowController")) as! NSWindowController
        
        // Present the UI
        self.showWindow()
        
        // Check the debug flag for showing rules preferences on launch
        if debugging.showRulesPreferencesOnLaunch {
            self.showRulesPreferences()
            // Check the debug flag for showing security preferences on launch
        } else if debugging.showSecurityPreferencesOnLaunch {
            self.showSecurityPreferences()
            // Check the debug flag for showing billing preferences on launch
        } else if debugging.showBillingPreferencesOnLaunch {
            self.showBillingPreferences()
        }
    }
    
    // Gets called when the App launches/opens via URL
    @objc func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            print("Handling URL: \(urlString)")
            if let url = URLComponents(string: urlString), let queryItems = url.queryItems, url.scheme == "balancemymoney" {
                if url.host == "coinbase" {
                    print("Handling coinbase callback")
                    
                    var code: String?
                    var state: String?
                    for queryItem in queryItems {
                        if queryItem.name == "code" {
                            code = queryItem.value
                        } else if queryItem.name == "state" {
                            state = queryItem.value
                        }
                    }
                    
                    if let code = code, let state = state {
                        CoinbaseApi.handleAuthenticationCallback(state: state, code: code) { success, error in
                            if !success {
                                print("Error handling Coinbase authentication callback: \(String(describing: error))")
                            }
                            
                            NotificationCenter.postOnMainThread(name: Notifications.ShowTabIndex, object: nil, userInfo: [Notifications.Keys.TabIndex: Tab.accounts.rawValue])
                            NotificationCenter.postOnMainThread(name: Notifications.ShowTabs)
                            
                            // Temporary hack to get Accounts tab showing correct data
                            NotificationCenter.postOnMainThread(name: Notifications.SyncCompleted)
                            
                            self.showPopover()
                        }
                    } else {
                        print("Missing query items, code: \(String(describing: code)), state: \(String(describing: state))")
                    }
                }
            }
        } else {
            print("No valid URL to handle")
        }
    }
    
    //
    // MARK: UI Display
    //
    
    fileprivate var macBartenderRunning: Bool {
        var running = false
        let runningApplications = NSWorkspace.shared.runningApplications
        for app in runningApplications {
            if app.bundleIdentifier == "com.surteesstudios.Bartender" {
                running = true
                break
            }
        }
        return running
    }

    func showWindow() {
        contentViewController = PopoverViewController()
        
        if showInWindow {
            // Window (for debugging)
            window.contentViewController = contentViewController
            window.styleMask = [.closable, .titled, .miniaturizable]
            window.makeKeyAndOrderFront(NSApp)
            window.center()
        } else {
            // Status bar
            if debugging.keepPopoverPinned {
                statusItem.windowConfiguration.isPinned = true
            } else if defaults.firstLaunch {
                statusItem.windowConfiguration.isPinned = true
                async(after: 5.5) {
                    self.statusItem.windowConfiguration.isPinned = false
                    defaults.firstLaunch = false
                }
            }
            statusItem.windowConfiguration.presentationTransition = .slideAndFade
            statusItem.windowConfiguration.animationDuration = 0.13
            statusItem.windowConfiguration.toolTip = "Balance"
            statusItem.windowConfiguration.backgroundColor = CurrentTheme.defaults.backgroundColor
            statusItem.present(with: NSImage(named: NSImage.Name(rawValue: "statusIcon")), contentViewController: contentViewController)
            statusItem.statusItem.button?.setAccessibilityLabel("Balance")
            statusItem.drawBorder = CurrentTheme.type == .light
            
            statusItem.shouldShowHandler = { statusItem in
                if appLock.locked && appLock.touchIdAvailable && appLock.touchIdEnabled {
                    self.promptTouchId()
                    return false
                }
                self.showPopover(force: true)
                return false
            }
            
            if debugging.betaExpired {
                let alert = NSAlert()
                alert.alertStyle = .informational
                alert.messageText = "Balance App"
                alert.informativeText = "This beta build has expired. Please obtain an updated beta version to continue use."
                alert.addButton(withTitle: "OK")
                alert.runModal()
                NSApp.terminate(nil)
            }
            
            // Delay the popover so that the animation is smooth and so that it appears in the correct place
            // for users with Mac Bartender
            var delay = macBartenderRunning ? 2.0 : 1.0
            delay = debugging.fastLaunch ? 0.0 : delay
            async(after: delay) {
                var showedAlert = false
                if !defaults.promptedForLaunchAtLogin && InstitutionRepository.si.institutionsCount > 0 {
                    defaults.promptedForLaunchAtLogin = true
                    if !defaults.launchAtLogin {
                        showedAlert = true
                        let alert = NSAlert()
                        alert.alertStyle = .informational
                        alert.messageText = "Launch Automatically"
                        alert.informativeText = "Would you like to launch Balance automatically when you login? This can be changed later in Preferences."
                        alert.addButton(withTitle: "Yes")
                        alert.addButton(withTitle: "No")
                        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                            defaults.launchAtLogin = true
                        }
                        self.showPopover()
                    }
                }
                
                if !self.launchedAtLogin && !showedAlert {
                    self.showPopover()
                }
            }
        }
    }
    
    func showPreferences() {
        if !appLock.locked {
            pinned = true
            if let prefsWindow = preferencesWindowController.window {
                if prefsWindow.parent == nil {
                    prefsWindow.delegate = self
                    contentViewController.view.window?.addChildWindow(prefsWindow, ordered: .above)
                    preferencesWindowController.showWindow(nil)
                    prefsWindow.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                    
                    // Analytics
                    BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Preferences opened")
                } else {
                    prefsWindow.makeKeyAndOrderFront(nil)
                }
            }
        }
    }
    
    func showRulesPreferences() {
        if !appLock.locked {
            showPreferences()
            if let prefsController = preferencesWindowController.contentViewController as? PreferencesViewController {
                prefsController.selectedTabViewItemIndex = 2
            }
        }
    }

    func showSecurityPreferences() {
        if !appLock.locked {
            showPreferences()
            if let prefsController = preferencesWindowController.contentViewController as? PreferencesViewController {
                prefsController.selectedTabViewItemIndex = 4
            }
        }
    }
    
    func showBillingPreferences() {
        if !appLock.locked {
            showPreferences()
            if let prefsController = preferencesWindowController.contentViewController as? PreferencesViewController {
                prefsController.selectedTabViewItemIndex = 3
            }
        }
    }
    
    func promptTouchId() {
        if appLock.locked && appLock.touchIdAvailable && appLock.touchIdEnabled {
            appLock.authenticateTouchId(reason: "unlock Balance") { success, error in
                async(after: 0.1) {
                    self.showPopover(force: true)
                    if success {
                        self.contentViewController.unlockUserInterface(animated: false, delayViewAppearCalls: true)
                    }
                }
            }
        }
    }
    
    func resizeWindow(_ size: CGSize, animated: Bool) {
        var finalSize = size
        if size.height > maxHeight {
            finalSize.height = maxHeight
        }
        statusItem.resizeWindow(finalSize, animated: animated)
    }
    
    func resizeWindowHeight(_ height: CGFloat, animated: Bool) {
        let finalHeight = height > maxHeight ? maxHeight : height
        statusItem.resizeWindowHeight(finalHeight, animated: animated)
    }
    
    func resizeWindowToMaxHeight(animated: Bool) {
        statusItem.resizeWindowHeight(maxHeight, animated: animated)
    }
    
//    // Resize only if the view is in the view hierarchy
//    func resizeWindow(sender: AnyObject, size: NSSize, animated: Bool = true) {
//        var view: NSView?
//        if let vc = sender as? NSViewController {
//            view = vc.view
//        } else if let v = sender as? NSView {
//            view = v
//        }
//        
//        if let view = view {
//            if view.window != nil {
//                statusItem.resizeWindow(size, animated: animated)
//            }
//        } else {
//            statusItem.resizeWindow(size, animated: animated)
//        }
//    }
//    
//    func resizeWindowHeight(sender: AnyObject, height: CGFloat, animated: Bool = true) {
//        let size = NSSize(width: contentViewController.view.window!.frame.size.width, height: height)
//        resizeWindow(sender: sender, size: size, animated: animated)
//    }
    
    func relaunch() {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 0.2; open \"\(Bundle.main.bundlePath)\""]
        task.launch()
        NSApp.terminate(nil)
    }
    
    func sendFeedback() {
        let urlString = "https://github.com/balancemymoney/BalanceForBlockchain/issues"
        _ = try? NSWorkspace.shared.open(URL(string: urlString)!, options: [], configuration: [:])
    }
    
    func checkForUpdates(sender: Any) {
        SUUpdater.shared().checkForUpdates(sender)
    }
    
    func quitApp() {
        NSApp.terminate(nil)
    }
    
    //
    // MARK: Notifications
    //
    
    fileprivate func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(togglePopover), name: Notifications.TogglePopover)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showPopover), name: Notifications.ShowPopover)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(hidePopover), name: Notifications.HidePopover)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(displayServerMessage(_:)), name: Notifications.DisplayServerMessage)
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.TogglePopover)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ShowPopover)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.HidePopover)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.DisplayServerMessage)
    }
    
    @objc fileprivate func togglePopover() {
        if statusItem.isStatusItemWindowVisible {
            hidePopover()
        } else {
            showPopover()
        }
    }
    
    @objc fileprivate func showPopover(force: Bool = false) {
        if !statusItem.isStatusItemWindowVisible && (force || statusItem.shouldShowHandler(statusItem)) {
            statusItem.showWindow()
            
            // Check for server message
            serverMessage.checkForMessage()
        }
    }
    
    @objc fileprivate func hidePopover() {
        if statusItem.isStatusItemWindowVisible {
            statusItem.dismissWindow()
        }
    }
    
    @objc fileprivate func displayServerMessage(_ notification: Notification) {
        if let title = notification.userInfo?[Notifications.Keys.ServerMessageTitle] as? String, let content = notification.userInfo?[Notifications.Keys.ServerMessageContent] as? String, let okButton = notification.userInfo?[Notifications.Keys.ServerMessageOKButton] as? String {
            
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = title
            alert.informativeText = content
            alert.addButton(withTitle: okButton)
            
            hidePopover()
            
            async(after: 0.5) {
                alert.runModal()
            }
        }
    }
}

// Preferences window delegate
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let closingWindow = notification.object as? NSWindow, closingWindow == preferencesWindowController.window {
            contentViewController.view.window?.removeChildWindow(closingWindow)
        }
        
        pinned = false
    }
}

// Local notifications delegate
extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        NotificationCenter.postOnMainThread(name: Notifications.ShowTabIndex, object: nil, userInfo: [Notifications.Keys.TabIndex: Tab.feed.rawValue])
        async(after: 0.5) {
            self.showPopover()
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}   
