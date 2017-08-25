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
        #if os(OSX)
        if #available(OSX 10.12.2, *) {
            if debugging.fakeTouchId {
                return true
            } else {
                // Fix for OS X 10.12.1 build 16B2555
                if !isBadSierraTouchIdRelease {
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
            PlaidApi.deleteInstitution(institutionId: institution.institutionId)
        }
        
        DispatchQueue.userInitiated.async {
            let waitUntilTime = Date().addingTimeInterval(5.0)
            while waitUntilTime.timeIntervalSince(waitUntilTime) > 0 {
                if InstitutionRepository.si.institutionsCount == 0 {
                    DispatchQueue.main.async {
                        self.lockEnabled = false
                        AppDelegate.sharedInstance.relaunch()
                    }
                    break
                }
                usleep(100000)
            }
            DispatchQueue.main.async {
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
    
    // Apple released two versions of 10.12.1, 16B2555 and 16B2657. Only the latter supports deviceOwnerAuthenticationWithBiometrics.
    // The former just crashes, yay.
    // Hack for Apple's shitty ability to mark new features with correct OS versions
    fileprivate var isBadSierraTouchIdRelease: Bool {
        var size = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: Int(size))
        sysctlbyname("kern.osversion", &machine, &size, nil, 0)
        let string = String(cString: machine)
        
        return string.hasSuffix("16B2555")
    }
    #endif
}
