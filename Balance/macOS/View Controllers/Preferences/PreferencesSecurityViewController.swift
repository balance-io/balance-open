//
//  PreferencesSecurityViewController.swift
//  Bal
//

import Foundation
import Crashlytics

class PreferencesSecurityViewController: NSViewController {
    
    //Password
    fileprivate let passwordTitleField = LabelField()
    fileprivate let passwordExplanationField = LabelField()
    fileprivate let togglePasswordButton = Button()
    fileprivate let changePasswordButton = Button()
    
    fileprivate let firstDividerBox = NSBox()
    
    //Auto-Lock
    fileprivate let autoLockTitleField = LabelField()
    fileprivate let lockQuitTitleField = LabelField()
    fileprivate let lockSleepCheckBox = Button()
    fileprivate let lockScreenSaverCheckBox = Button()
    fileprivate let lockCloseCheckBox = Button()
    
    fileprivate let secondDividerBox = NSBox()
    
    //Touch ID
    fileprivate let touchIDTitleField = LabelField()
    fileprivate let touchIDIconImageView = ImageView()
    fileprivate let touchIDExplanationField = LabelField()
    fileprivate let toggleTouchIDButton = Button()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTitleField.stringValue = "Password"
        passwordTitleField.alignment = .right
        passwordTitleField.font = NSFont.systemFont(ofSize: 15)
        passwordTitleField.textColor = NSColor.black
        self.view.addSubview(passwordTitleField)
        passwordTitleField.snp.makeConstraints{ make in
            make.width.equalTo(80)
            make.top.equalTo(self.view).offset(20)
            make.leading.equalTo(self.view).offset(20)
        }
        
        passwordExplanationField.stringValue = "Lock Balance with a password"
        passwordExplanationField.alignment = .left
        passwordExplanationField.font = NSFont.systemFont(ofSize: 12)
        passwordExplanationField.textColor = NSColor.black
        self.view.addSubview(passwordExplanationField)
        passwordExplanationField.snp.makeConstraints{ make in
            make.centerY.equalTo(passwordTitleField.snp.centerY)
            make.leading.equalTo(passwordTitleField.snp.trailing).offset(20)
        }

        togglePasswordButton.wantsLayer = true
        togglePasswordButton.bezelStyle = .texturedRounded
        togglePasswordButton.target = self
        self.view.addSubview(togglePasswordButton)
        togglePasswordButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordExplanationField)
            make.trailing.equalTo(self.view).offset(-20)
        }
        
        changePasswordButton.wantsLayer = true
        changePasswordButton.bezelStyle = .texturedRounded
        changePasswordButton.title = "Change..."
        changePasswordButton.setAccessibilityLabel("Change Password")
        changePasswordButton.action = #selector(showChangePasswordSheet)
        if appLock.lockEnabled {
            changePasswordButton.isHidden = false
        } else {
            changePasswordButton.isHidden = true
        }
        changePasswordButton.target = self
        self.view.addSubview(changePasswordButton)
        changePasswordButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordExplanationField)
            make.trailing.equalTo(togglePasswordButton.snp.leading).offset(-10)
        }
        
        firstDividerBox.title = ""
        firstDividerBox.boxType = .separator
        self.view.addSubview(firstDividerBox)
        firstDividerBox.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(passwordExplanationField.snp.bottom).offset(15)
            make.leading.equalTo(self.view).offset(20)
            make.trailing.equalTo(self.view).offset(-20)
        }
        
        //Auto-Lock
        
        autoLockTitleField.stringValue = "Auto-Lock"
        autoLockTitleField.alignment = .right
        autoLockTitleField.font = NSFont.systemFont(ofSize: 15)
        autoLockTitleField.textColor = NSColor.black
        self.view.addSubview(autoLockTitleField)
        autoLockTitleField.snp.makeConstraints{ make in
            make.width.equalTo(80)
            make.top.equalTo(firstDividerBox.snp.bottom).offset(15)
            make.leading.equalTo(self.view).offset(20)
        }
        
        lockQuitTitleField.stringValue = "Balance locks when you quit the app. Also:"
        lockQuitTitleField.alignment = .left
        lockQuitTitleField.font = NSFont.systemFont(ofSize: 12)
        lockQuitTitleField.textColor = NSColor.black
        self.view.addSubview(lockQuitTitleField)
        lockQuitTitleField.snp.makeConstraints{ make in
            make.width.equalTo(250)
            make.centerY.equalTo(autoLockTitleField.snp.centerY)
            make.leading.equalTo(autoLockTitleField.snp.trailing).offset(20)
        }
        
        lockSleepCheckBox.setButtonType(.switch)
        lockSleepCheckBox.font = NSFont.systemFont(ofSize: 12)
        lockSleepCheckBox.title = "Lock on sleep"
        lockSleepCheckBox.setAccessibilityLabel("Lock on sleep")
        lockSleepCheckBox.action = #selector(lockSleepCheckBoxPress)
        lockSleepCheckBox.target = self
        lockSleepCheckBox.state = appLock.lockOnSleep ? .on : .off
        self.view.addSubview(lockSleepCheckBox)
        lockSleepCheckBox.snp.makeConstraints{ make in
            make.top.equalTo(lockQuitTitleField.snp.bottom).offset(12)
            make.leading.equalTo(lockQuitTitleField)
        }
        
        lockScreenSaverCheckBox.setButtonType(.switch)
        lockScreenSaverCheckBox.font = NSFont.systemFont(ofSize: 12)
        lockScreenSaverCheckBox.title = "Lock when screensaver is activated"
        lockScreenSaverCheckBox.setAccessibilityLabel("Lock when screensaver is activated")
        lockScreenSaverCheckBox.action = #selector(lockScreenSaverCheckBoxPress)
        lockScreenSaverCheckBox.target = self
        lockScreenSaverCheckBox.state = appLock.lockOnScreenSaver ? .on : .off
        self.view.addSubview(lockScreenSaverCheckBox)
        lockScreenSaverCheckBox.snp.makeConstraints{ make in
            make.top.equalTo(lockSleepCheckBox.snp.bottom).offset(12)
            make.leading.equalTo(lockSleepCheckBox)
        }

        lockCloseCheckBox.setButtonType(.switch)
        lockCloseCheckBox.font = NSFont.systemFont(ofSize: 12)
        lockCloseCheckBox.title = "Lock every time the app window is closed"
        lockCloseCheckBox.setAccessibilityLabel("Lock every time the app window is closed")
        lockCloseCheckBox.action = #selector(lockCloseCheckboxPress)
        lockCloseCheckBox.target = self
        lockCloseCheckBox.state = appLock.lockOnPopoverClose ? .on : .off
        self.view.addSubview(lockCloseCheckBox)
        lockCloseCheckBox.snp.makeConstraints{ make in
            make.top.equalTo(lockScreenSaverCheckBox.snp.bottom).offset(12)
            make.leading.equalTo(lockScreenSaverCheckBox)
        }
        
        if appLock.touchIdAvailable {
            secondDividerBox.title = ""
            secondDividerBox.boxType = .separator
            self.view.addSubview(secondDividerBox)
            secondDividerBox.snp.makeConstraints { make in
                make.height.equalTo(1)
                make.top.equalTo(lockCloseCheckBox.snp.bottom).offset(15)
                make.leading.equalTo(self.view).offset(20)
                make.trailing.equalTo(self.view).offset(-20)
            }
            
            touchIDTitleField.stringValue = "Touch ID"
            touchIDTitleField.alignment = .right
            touchIDTitleField.font = NSFont.systemFont(ofSize: 15)
            touchIDTitleField.textColor = NSColor.black
            self.view.addSubview(touchIDTitleField)
            touchIDTitleField.snp.makeConstraints{ make in
                make.width.equalTo(80)
                make.top.equalTo(secondDividerBox.snp.bottom).offset(25)
                make.leading.equalTo(self.view).offset(20)
            }
            
            touchIDIconImageView.image = NSImage(named: NSImage.Name(rawValue: "touch-id-preferences-icon"))
            touchIDIconImageView.setAccessibilityLabel("Preview of how Balance looks.")
            self.view.addSubview(touchIDIconImageView)
            touchIDIconImageView.snp.makeConstraints{ make in
                make.width.equalTo(36)
                make.height.equalTo(36)
                make.centerY.equalTo(touchIDTitleField)
                make.leading.equalTo(touchIDTitleField.snp.trailing).offset(20)
            }
            
            touchIDExplanationField.stringValue = "Unlock Balance with your fingerprint"
            touchIDExplanationField.alignment = .left
            touchIDExplanationField.font = NSFont.systemFont(ofSize: 12)
            touchIDExplanationField.textColor = NSColor.black
            self.view.addSubview(touchIDExplanationField)
            touchIDExplanationField.snp.makeConstraints{ make in
                make.centerY.equalTo(touchIDIconImageView.snp.centerY)
                make.leading.equalTo(touchIDIconImageView.snp.trailing).offset(15)
            }
            
            toggleTouchIDButton.wantsLayer = true
            toggleTouchIDButton.bezelStyle = .texturedRounded
            toggleTouchIDButton.target = self
            toggleTouchIDButton.sizeToFit()
            self.view.addSubview(toggleTouchIDButton)
            toggleTouchIDButton.snp.makeConstraints { make in
                make.centerY.equalTo(touchIDExplanationField)
                make.trailing.equalTo(self.view).offset(-20)
            }
        } else {
            self.view.setFrameSize(NSSize(width: 500, height: 190))
        }
        
        updateButtonStates()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateButtonStates()
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(windowDidEndSheet(notification:)), name: NSWindow.didEndSheetNotification, object: AppDelegate.sharedInstance.preferencesWindowController.window!)
    }
    
    override func viewWillDisappear() {
        super.viewDidDisappear()
        NotificationCenter.removeObserverOnMainThread(self, name: NSWindow.didEndSheetNotification, object: AppDelegate.sharedInstance.preferencesWindowController.window!)
    }
    
    func updateButtonStates() {
        let lockEnabled = appLock.lockEnabled
        changePasswordButton.isHidden = !lockEnabled
        changePasswordButton.isEnabled = lockEnabled
        
        let title = lockEnabled ? "Disable" : "Enable"
        let accessibilityLabel = lockEnabled ? "Disable Password" : "Enable Password"
        let action = lockEnabled ? #selector(disablePassword) : #selector(showSetPasswordSheet)
        togglePasswordButton.title = title
        togglePasswordButton.setAccessibilityLabel(accessibilityLabel)
        togglePasswordButton.action = action
        
        autoLockTitleField.alphaValue = appLock.lockEnabled ? 1.0 : 0.4
        lockQuitTitleField.alphaValue = appLock.lockEnabled ? 1.0 : 0.4
        lockSleepCheckBox.isEnabled = appLock.lockEnabled
        lockScreenSaverCheckBox.isEnabled = appLock.lockEnabled
        lockCloseCheckBox.isEnabled = appLock.lockEnabled
        
        toggleTouchIDButton.isEnabled = lockEnabled
        if appLock.touchIdEnabled {
            toggleTouchIDButton.title = "Disable"
            toggleTouchIDButton.setAccessibilityLabel("Disable Touch ID")
            toggleTouchIDButton.action = #selector(disableTouchID)
        } else {
            toggleTouchIDButton.title = "Enable"
            toggleTouchIDButton.setAccessibilityLabel("Enable Touch ID")
            toggleTouchIDButton.action = #selector(enableTouchID)
        }
        
        if appLock.touchIdAvailable {
            touchIDTitleField.alphaValue = appLock.lockEnabled ? 1.0 : 0.4
            touchIDIconImageView.alphaValue = appLock.lockEnabled ? 1.0 : 0.4
            touchIDExplanationField.alphaValue = appLock.lockEnabled ? 1.0 : 0.4
        }
    }
    
    @objc func showSetPasswordSheet(){
        let alertViewController = SetPasswordViewController(completionBlock: {
            self.updateButtonStates()
        })
        self.presentViewControllerAsSheet(alertViewController)
    }
    
    @objc func showChangePasswordSheet(){
        let alertViewController = ChangePasswordViewController()
        self.presentViewControllerAsSheet(alertViewController)
    }
    
    @objc func disablePassword() {
        let alertViewController = DisablePasswordViewController(completionBlock: {
            self.updateButtonStates()
        })
        self.presentViewControllerAsSheet(alertViewController)
    }
    
    @objc func lockSleepCheckBoxPress(_ sender:NSButton) {
        let enabled = (sender.state == .on)
        appLock.lockOnSleep = enabled
        sender.state = appLock.lockOnSleep ? .on : .off
    }
    
    @objc func lockScreenSaverCheckBoxPress(_ sender:NSButton) {
        let enabled = (sender.state == .on)
        appLock.lockOnScreenSaver = enabled
        sender.state = appLock.lockOnScreenSaver ? .on : .off
    }
    
    @objc func lockCloseCheckboxPress(_ sender:NSButton) {
        let enabled = (sender.state == .on)
        appLock.lockOnPopoverClose = enabled
        sender.state = appLock.lockOnPopoverClose ? .on : .off
    }
    
    @objc func disableTouchID() {
        appLock.authenticateTouchId(reason: "disable Touch ID unlocking") { success, error in
            if success {
                appLock.touchIdEnabled = false
                self.updateButtonStates()
            }
        }
    }
    
    @objc func enableTouchID() {
        appLock.authenticateTouchId(reason: "enable Touch ID unlocking") { success, error in
            if success {
                appLock.touchIdEnabled = true
                self.updateButtonStates()
            }
        }
    }
    
    @objc func windowDidEndSheet(notification: Notification) {
        updateButtonStates()
    }
}
