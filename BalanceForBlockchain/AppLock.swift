//
//  AppLock.swift
//  Bal
//
//  Created by Benjamin Baron on 11/1/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import LocalAuthentication

class AppLock {
    var locked = false
    
    var password: String? {
        get {
            return keychain[KeychainAccounts.AppLock, KeychainKeys.Password]
        }
        set {
            keychain[KeychainAccounts.AppLock, KeychainKeys.Password] = newValue
        }
    }
    
    var passwordHint: String? {
        get {
            return keychain[KeychainAccounts.AppLock, KeychainKeys.PasswordHint]
        }
        set {
            keychain[KeychainAccounts.AppLock, KeychainKeys.PasswordHint] = newValue
        }
    }
    
    var lockEnabled: Bool {
        get {
            if let string = keychain[KeychainAccounts.AppLock, KeychainKeys.LockEnabled] {
                return string == "true"
            }
            return false
        }
        set {
            let string = newValue ? "true" : "false"
            keychain[KeychainAccounts.AppLock, KeychainKeys.LockEnabled] = string
        }
    }
    
    var lockOnSleep: Bool {
        get {
            if let string = keychain[KeychainAccounts.AppLock, KeychainKeys.LockOnSleep] {
                return string == "true"
            }
            
            // Default to true
            return true
        }
        set {
            let string = newValue ? "true" : "false"
            keychain[KeychainAccounts.AppLock, KeychainKeys.LockOnSleep] = string
        }
    }
    
    var lockOnScreenSaver: Bool {
        get {
            if let string = keychain[KeychainAccounts.AppLock, KeychainKeys.LockOnScreenSaver] {
                return string == "true"
            }
            
            // Default to true
            return true
        }
        set {
            let string = newValue ? "true" : "false"
            keychain[KeychainAccounts.AppLock, KeychainKeys.LockOnScreenSaver] = string
        }
    }
    
    var lockOnPopoverClose: Bool {
        get {
            if let string = keychain[KeychainAccounts.AppLock, KeychainKeys.LockOnPopoverClose] {
                return string == "true"
            }
            
            // Default to true
            return true
        }
        set {
            let string = newValue ? "true" : "false"
            keychain[KeychainAccounts.AppLock, KeychainKeys.LockOnPopoverClose] = string
        }
    }
    
    var touchIdEnabled: Bool {
        get {
            if let string = keychain[KeychainAccounts.AppLock, KeychainKeys.TouchIdEnabled] {
                return string == "true"
            }
            return false
        }
        set {
            let string = newValue ? "true" : "false"
            keychain[KeychainAccounts.AppLock, KeychainKeys.TouchIdEnabled] = string
        }
    }
    
    var touchIdAvailable: Bool {
        if #available(OSX 10.12.2, *) {
            do {
                var touchIdAvailable = false
                try ObjC.catchException {
                    var error: NSError?
                    touchIdAvailable = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
                    if let error = error {
                        log.error("Error checking for touch id: \(error)")
                    }
                }
                return touchIdAvailable
            } catch let error {
                // Policy doesn't exist
                log.error("Error checking for touch id: \(error)")
                return false
            }
        }
        return false
    }
    
    func authenticateTouchId(reason: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        if #available(OSX 10.12.2, *) {
            let context = LAContext()
            //let policy: LAPolicy = debugging.fakeTouchId ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
            let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
            do {
                try ObjC.catchException {
                    if context.canEvaluatePolicy(policy, error: nil) {
                        context.evaluatePolicy(policy, localizedReason: reason) { success, evaluateError in
                            if success {
                                // User authenticated successfully, take appropriate action
                                DispatchQueue.main.async {
                                    completion(true, nil)
                                }
                            } else {
                                // User did not authenticate successfully, look at error and take appropriate action
                                DispatchQueue.main.async {
                                    completion(false, evaluateError)
                                }
                            }
                        }
                    } else {
                        // Could not evaluate policy; look at authError and present an appropriate message to user
                        DispatchQueue.main.async {
                            completion(false, nil)
                        }
                    }
                }
            } catch {
                // Policy doesn't exist
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        } else {
            // Fail on earlier versions
            DispatchQueue.main.async {
                completion(false, nil)
            }
        }
    }
    
    func resetAppData() {
//        let institutions = Institution.allInstitutions()
//        for institution in institutions {
//            plaidApi.removeUser(institutionId: institution.institutionId)
//        }
//        
//        DispatchQueue.userInitiated.async {
//            let waitUntilTime = Date().addingTimeInterval(5.0)
//            while waitUntilTime.timeIntervalSince(waitUntilTime) > 0 {
//                if Institution.institutionsCount == 0 {
//                    DispatchQueue.main.async {
//                        self.lockEnabled = false
//                        AppDelegate.sharedInstance.relaunch()
//                    }
//                    break
//                }
//                usleep(100000)
//            }
//            DispatchQueue.main.async {
//                let alert = NSAlert()
//                alert.addButton(withTitle: "OK")
//                alert.messageText = "Unable to remove all accounts"
//                alert.informativeText = "We were unable to remove all accounts, either due to a network error or some other problem. Please try again and ensure you have internet access."
//                alert.alertStyle = .informational
//                if alert.runModal() == NSAlertFirstButtonReturn {
//                    AppDelegate.sharedInstance.showBillingPreferences()
//                }
//            }
//        }
//        
    }
}
