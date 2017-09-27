//
//  LockViewController.swift
//  Bal
//
//  Created by Benjamin Baron, a legend, on 11/5/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import LocalAuthentication

class LockViewController: NSViewController, NSTextFieldDelegate {
    
    //Possible States
    fileprivate let hintVisible = true
    fileprivate let forgottenPasswordButtonVisible = true
    
    //Interface
    fileprivate let titleField = LabelField()
    fileprivate let explanationField = LabelField()
    fileprivate let passwordField = SignUpTextField(type: .balancePassword)
    
    fileprivate let touchIdButton = Button()

    fileprivate let hintField = LabelField()
    fileprivate let forgottenPasswordButton = Button()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        AppDelegate.sharedInstance.resizeWindowHeight(200, animated: true)
        passwordField.stringValue = ""
        touchIdButton.isHidden = !appLock.touchIdEnabled
        passwordField.snp.updateConstraints { make in
            if appLock.touchIdEnabled {
                make.leading.equalTo(self.view).offset(80)
            } else {
                make.leading.equalTo(self.view).offset(40)
            }
        }
    }
    
    override func loadView() {
        self.view = View()
        
        titleField.stringValue = "Balance"
        titleField.font = CurrentTheme.lock.titleFont
        titleField.textColor = CurrentTheme.defaults.foregroundColor
        titleField.alignment = .center
        titleField.usesSingleLineMode = true
        self.view.addSubview(titleField)
        titleField.snp.makeConstraints { make in
            make.leading.equalTo(self.view).inset(10)
            make.trailing.equalTo(self.view).inset(10)
            make.top.equalTo(self.view).inset(19)
        }
        
        if appLock.touchIdEnabled {
            explanationField.stringValue = "Touch ID or enter your password"
        } else {
            explanationField.stringValue = "Please enter your password"
        }
        explanationField.font = CurrentTheme.lock.explanationFont
        explanationField.textColor = CurrentTheme.defaults.foregroundColor
        explanationField.alphaValue = 0.7
        explanationField.alignment = .center
        self.view.addSubview(explanationField)
        explanationField.snp.makeConstraints { make in
            make.centerX.equalTo(titleField)
            make.top.equalTo(titleField.snp.bottom).offset(12)
            make.leading.equalTo(self.view).offset(20)
            make.trailing.equalTo(self.view).offset(-20)
        }
        
        passwordField.delegate = self
        passwordField.layerBackgroundColor = CurrentTheme.lock.passwordBackgroundColor
        passwordField.activeBorderColor = CurrentTheme.lock.passwordActiveBorderColor
        passwordField.inactiveBorderColor = CurrentTheme.lock.passwordInactiveBorderColor
        passwordField.textColor = CurrentTheme.lock.passwordTextColor
        passwordField.placeHolderStringColor = CurrentTheme.lock.passwordPlaceholderColor
        self.view.addSubview(passwordField)
        passwordField.snp.makeConstraints{ make in
            make.height.equalTo(30)
            make.top.equalTo(explanationField.snp.bottom).offset(20)
            if appLock.touchIdEnabled {
                make.leading.equalTo(self.view).offset(80)
            } else {
                make.leading.equalTo(self.view).offset(40)
            }
            make.trailing.equalTo(self.view).offset(-110)
        }
        
        let button = Button()
        button.bezelStyle = .rounded
        button.title = "Unlock"
        button.setAccessibilityLabel("Unlock")
        button.target = self
        button.action = #selector(unlock)
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(25)
            make.centerY.equalTo(passwordField.snp.centerY)
            make.leading.equalTo(passwordField.snp.trailing).offset(10)
//            make.centerX.equalTo(self.view)
//            make.bottom.equalTo(self.view).offset(-30)
        }
        
        touchIdButton.isHidden = !appLock.touchIdEnabled
        touchIdButton.isBordered = false
        touchIdButton.imageScaling = .scaleProportionallyUpOrDown
        touchIdButton.imagePosition = .imageOnly
        touchIdButton.image = NSImage(named: NSImage.Name(rawValue: "touch-id-preferences-icon"))
        touchIdButton.target = self
        touchIdButton.action = #selector(promptTouchId)
        touchIdButton.setAccessibilityLabel("Touch ID")
        self.view.addSubview(touchIdButton)
        touchIdButton.snp.makeConstraints{ make in
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.centerY.equalTo(passwordField)
            make.trailing.equalTo(passwordField.snp.leading).offset(-10)
            //            make.leading.equalTo(touchIDTitleField.snp.trailing).offset(20)
        }
        
        hintField.font = NSFont.systemFont(ofSize: 11)
        hintField.textColor = CurrentTheme.defaults.foregroundColor
        hintField.alphaValue = 0.0
        hintField.lineBreakMode = .byWordWrapping
        hintField.alignment = .center
        self.view.addSubview(hintField)
        hintField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(250)
            make.top.equalTo(passwordField.snp.bottom).offset(10)
            make.centerX.equalTo(self.view)
        }
        
        forgottenPasswordButton.bezelStyle = .recessed
        forgottenPasswordButton.isHidden = true
        forgottenPasswordButton.isBordered = false
        forgottenPasswordButton.title = "Forgotten Password?"
        forgottenPasswordButton.setAccessibilityLabel("Forgotten Password?")
        forgottenPasswordButton.target = self
        forgottenPasswordButton.action = #selector(forgottenPasswordAlert)
        self.view.addSubview(forgottenPasswordButton)
        forgottenPasswordButton.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.centerX.equalTo(self.view)
            make.top.equalTo(hintField.snp.bottom).offset(5)
        }
    }
    
    @objc fileprivate func promptTouchId() {
        NotificationCenter.postOnMainThread(name: Notifications.HidePopover)
        AppDelegate.sharedInstance.promptTouchId()
    }

    @objc fileprivate func unlock() {
        if passwordField.stringValue == appLock.password {
            NotificationCenter.postOnMainThread(name: Notifications.UnlockUserInterface)
            hintField.alphaValue = 0.0
            forgottenPasswordButton.isHidden = true
        } else {
            self.view.window?.shake()
            hintField.stringValue = appLock.passwordHint ?? ""
            hintField.alphaValue = 0.8
            forgottenPasswordButton.isHidden = false
        }
    }
    
    @objc func forgottenPasswordAlert() {
        AppDelegate.sharedInstance.pinned = true
        
        if userPasswordAvailable {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Remove Lock"
            alert.informativeText = "Your unlock password is securely stored within Balance, so we cannot reset it or send it to you over email. However, you can remove the lock by using your macOS user account password."
            alert.addButton(withTitle: "Yes, remove the lock")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: self.view.window!) { response in
                if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                    AppDelegate.sharedInstance.pinned = false
                    self.authenticateUserPassword(reason: "unlock Balance") { success, error in
                        if success {
                            appLock.lockEnabled = false
                            NotificationCenter.postOnMainThread(name: Notifications.UnlockUserInterface)
                            async(after: 0.8) {
                                NotificationCenter.postOnMainThread(name: Notifications.ShowPopover)
                            }
                        }
                    }
                } else {
                    AppDelegate.sharedInstance.pinned = false
                }
            }
        } else {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Reset Balance"
            alert.informativeText = "Your password is securely stored within Balance, so we cannot reset it or send it to you over email. If you have forgotten your password and want to use Balance, you have to reset the app.\n\nThis will delete all of your financial information and you will have to re-add your accounts."
            alert.addButton(withTitle: "Yes, reset Balance completely")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: self.view.window!) { response in
                if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                    let alert = NSAlert()
                    alert.alertStyle = .informational
                    alert.messageText = "Reset Balance"
                    alert.informativeText = "Are you sure you want to reset Balance? All accounts will need to be added again."
                    alert.addButton(withTitle: "Yes, I'm sure")
                    alert.addButton(withTitle: "Cancel")
                    alert.beginSheetModal(for: self.view.window!) { response in
                        AppDelegate.sharedInstance.pinned = false
                        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                            appLock.resetAppData()
                        }
                    }
                } else {
                    AppDelegate.sharedInstance.pinned = false
                }
            }
        }
    }
    
    var userPasswordAvailable: Bool {
        if #available(OSX 10.11, *) {
            do {
                var touchIdAvailable = false
                try ObjC.catchException {
                    var error: NSError?
                    touchIdAvailable = LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
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
    
    func authenticateUserPassword(reason: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        if #available(OSX 10.11, *) {
            let context = LAContext()
            do {
                try ObjC.catchException {
                    let policy: LAPolicy = .deviceOwnerAuthentication
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
        }  else {
            // Fail on earlier versions
            async { completion(false, nil) }
        }
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            unlock()
        }
        
        return false
    }
    
    func willDisplayPopover() {
        self.view.window?.makeFirstResponder(passwordField)
    }
}
