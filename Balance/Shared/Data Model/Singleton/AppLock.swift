//
//  AppLock.swift
//  Bal
//
//  Created by Benjamin Baron on 11/1/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import LocalAuthentication

fileprivate struct AutenticationInterval {
    
    let interval: TimeInterval
    let fromDate: Date
    
    var toDate: Date {
        return fromDate.addingTimeInterval(interval)
    }
    
    var isValid: Bool {
        let currentDate = Date()
        let fromDatePosition = currentDate.compare(fromDate)
        let isValidFromDate = fromDatePosition == .orderedDescending || fromDatePosition == .orderedSame
        let isValidToDate = currentDate.compare(toDate) == .orderedAscending
        
        return isValidFromDate && isValidToDate
        
    }
    
    init(timeInterval: Double) {
        fromDate = Date()
        interval = timeInterval
    }
    
}

class AppLock: AppLockServicesProtocol {

    private var interval: AutenticationInterval?
    private var appLocked = false
    
    var locked: Bool {
        set {
            appLocked = newValue
        }
        
        get {
            guard skipBlock else {
                return appLocked
            }

            return false
        }
    }
    
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
            guard !skipBlock else {
                return false
            }
            
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
            guard !skipBlock else {
                return false
            }
            
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
            guard !skipBlock else {
                return false
            }
            
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
            guard !skipBlock else {
                return false
            }
            
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
        #if os(OSX)
        if #available(OSX 10.12.2, *) {
            if debugging.fakeTouchId {
                return true
            } else {
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
        }
        return false
        #else
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
        #endif
    }
    
    func lock(until timeInterval: TimeInterval?) {
        guard let timeInterval = timeInterval else {
            self.interval = nil
            return
        }
        
        let interval = AutenticationInterval(timeInterval: timeInterval)
        guard interval.isValid else {
            self.interval = nil
            return
        }
        
        self.interval = interval
    }
    
    func authenticateTouchId(reason: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        if #available(OSX 10.12.2, *) {
            let context = LAContext()
            let policy: LAPolicy = debugging.fakeTouchId ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
            do {
                try ObjC.catchException {
                    if context.canEvaluatePolicy(policy, error: nil) {
                        context.evaluatePolicy(policy, localizedReason: reason) { success, evaluateError in
                            if success {
                                // User authenticated successfully, take appropriate action
                                async { completion(true, nil) }
                            } else {
                                // User did not authenticate successfully, look at error and take appropriate action
                                async { completion(false, evaluateError) }
                            }
                        }
                    } else {
                        // Could not evaluate policy; look at authError and present an appropriate message to user
                        async { completion(false, nil) }
                    }
                }
            } catch {
                // Policy doesn't exist
                async { completion(false, nil) }
            }
        } else {
            // Fail on earlier versions
            async { completion(false, nil) }
        }
    }
    
    #if os(OSX)
    func resetAppData() {
        let institutions = InstitutionRepository.si.allInstitutions()
        for institution in institutions {
            institution.delete()
        }
        
        DispatchQueue.userInitiated.async {
            let waitUntilTime = Date().addingTimeInterval(5.0)
            while waitUntilTime.timeIntervalSince(waitUntilTime) > 0 {
                if InstitutionRepository.si.institutionsCount == 0 {
                    async {
                        self.lockEnabled = false
                        AppDelegate.sharedInstance.relaunch()
                    }
                    break
                }
                usleep(100000)
            }
            async {
                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                alert.messageText = "Unable to remove all accounts"
                alert.informativeText = "We were unable to remove all accounts, either due to a network error or some other problem. Please try again and ensure you have internet access."
                alert.alertStyle = .informational
                if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                    AppDelegate.sharedInstance.showBillingPreferences()
                }
            }
        }
        
    }
    #endif
    
}

extension AppLock {
    
    var lockAfterMinutes: Bool {
        return interval?.isValid ?? false
    }
    
    var lockInterval: TimeInterval? {
        return interval?.interval
    }
    
    var shouldPrepareBlock: Bool {
        guard let interval = interval else {
            #if os(OSX)
                return appLocked
            #else
                return lockEnabled
            #endif
        }
        
        return !interval.isValid
    }
    
    private var  skipBlock: Bool {
        guard let interval = interval,
            interval.isValid else {
            return false
        }
        
        return true
    }
    
}
