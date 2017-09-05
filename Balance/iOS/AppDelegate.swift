//
//  AppDelegate.swift
//  balanceios
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static fileprivate(set) var sharedInstance: AppDelegate!
    
    // Private
    private let rootViewController = RootViewController()
    
    // Internal
    var window: UIWindow?
    
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
        // Window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.rootViewController
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        
        
        //////////////////
        //benDebugging()
        //////////////////
        
        // Initialize singletons
        initializeSingletons()
        
        // Initialize logging
        logging.setupLogging()
        
        // Initialize UserDefaults
        defaults.setupDefaults()
        print("feedRules: \(String(describing: defaults.feedRules))")
        
        // Initialize database
        database.create()
        
        // Access tokens and Realm syncing credentials for debugging
        #if DEBUG
        if !Testing.runningUiTests {
            if debugging.logAccessTokens {
                for institution in InstitutionRepository.si.allInstitutions() {
                    if let accessToken = institution.accessToken {
                        log.debug("(\(institution)): \(accessToken)")
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
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

