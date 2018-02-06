//
//  AppDelegate.swift
//  balanceios
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    static fileprivate(set) var sharedInstance: AppDelegate!
    let rootViewController = RootViewController()

    // NOTE: Must use var and optional here to comply with protocol and not cause any crashes
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // Swizzle all needed methods (can't use class initialize anymore since Swift 3.1)
        swizzleMethods()
        
        // Create a singleton reference
        AppDelegate.sharedInstance = self
        
        if (debugging.useMockSession) {
            URLProtocol.registerClass(PlaidDataMockingProtocol.self)
        }
    }
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Background fetch
        let hourInSeconds = 60.0 * 60.0
        application.setMinimumBackgroundFetchInterval(hourInSeconds)
        
        // Initialize singletons
        initializeSingletons()
        
        // Initialize logging
        logging.setupLogging()
        
        // Initialize UserDefaults
        defaults.setupDefaults()
        
        // Initialize database
        _ = database.create()
        
        // Initialyze crash logging and analytics
        analytics.setupAnalytics()
        
        // Access tokens and Realm syncing credentials for debugging (only Xcode builds)
        debugPrintInstitutionKeys()
        
        // Start monitoring network status
        networkStatus.startMonitoring()
        
        // Set first launch flag
        if defaults.firstLaunch {
            defaults.firstLaunch = false
        }
        
        // Window
        if let window = window {
            window.rootViewController = rootViewController
            window.backgroundColor = .white
            window.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        // Coinbase callback
        if let queryItems = urlComponents.queryItems, urlComponents.host == "coinbase" {
            var code: String?
            var state: String?
            
            for queryItem in queryItems {
                switch queryItem.name {
                case "code":
                    code = queryItem.value
                case "state":
                    state = queryItem.value
                default:()
                }
            }
            
            if let code = code, let state = state {
                CoinbaseApi.handleAuthenticationCallback(state: state, code: code) { success, error in
                    log.debug("success: \(success)  error: \(String(describing: error))")
                    
                    let institutionId = CoinbaseApi.existingInstitution?.institutionId
                    let result = CoinbaseAutenticationResult(succeeded: success, error: error, institutionId: institutionId)
                    let userInfo: [AnyHashable: Any] = [CoinbaseNotifications.Keys.authenticationResult: result]
                    NotificationCenter.postOnMainThread(name: CoinbaseNotifications.autenticationDidFinish, object: nil, userInfo: userInfo)
                    
                    syncManager.sync()
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        syncManager.sync(userInitiated: false, validateReceipt: false, skip: [.coinbase]) { (success, error) in
            let result: UIBackgroundFetchResult = success ? .newData : .failed
            completionHandler(result)
        }
    }
}
