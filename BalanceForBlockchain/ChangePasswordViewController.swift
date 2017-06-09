//
//  ChangePasswordViewController.swift
//  Bal
//
//  Created by Butler on 11/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class ChangePasswordViewController: NSViewController {
    
    let currentPasswordLabelField = LabelField()
    let currentPasswordField = SecureField()
    
    let passwordLabelField = LabelField()
    let passwordField = SecureField()
    let confirmLabelField = LabelField()
    let confirmField = SecureField()
    let hintLabelField = LabelField()
    let hintField = TextField()
    
    let cancelButton = Button()
    let createButton = Button()
    
    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        self.view = View()
        
        self.view.snp.makeConstraints{ make in
            make.width.equalTo(440)
            make.height.equalTo(230)
        }
        
        self.view.addSubview(currentPasswordField)
        currentPasswordField.snp.makeConstraints{ make in
            make.width.equalTo(280)
            make.top.equalTo(self.view).offset(20)
            make.leading.equalTo(140)
        }
        
        currentPasswordLabelField.stringValue = "Current Password:"
        currentPasswordLabelField.alignment = .right
        currentPasswordLabelField.font = NSFont.systemFont(ofSize: 12)
        currentPasswordLabelField.textColor = NSColor.black
        self.view.addSubview(currentPasswordLabelField)
        currentPasswordLabelField.snp.makeConstraints{ make in
            make.centerY.equalTo(currentPasswordField)
            make.trailing.equalTo(currentPasswordField.snp.leading).offset(-10)
        }
        
        self.view.addSubview(passwordField)
        passwordField.snp.makeConstraints{ make in
            make.width.equalTo(280)
            make.top.equalTo(currentPasswordField.snp.bottom).offset(15)
            make.leading.equalTo(140)
        }
        
        passwordLabelField.stringValue = "New Password:"
        passwordLabelField.alignment = .right
        passwordLabelField.font = NSFont.systemFont(ofSize: 12)
        passwordLabelField.textColor = NSColor.black
        self.view.addSubview(passwordLabelField)
        passwordLabelField.snp.makeConstraints{ make in
            make.centerY.equalTo(passwordField)
            make.trailing.equalTo(passwordField.snp.leading).offset(-10)
        }

        self.view.addSubview(confirmField)
        confirmField.snp.makeConstraints{ make in
            make.width.equalTo(280)
            make.top.equalTo(passwordField.snp.bottom).offset(10)
            make.leading.equalTo(140)
        }
        
        confirmLabelField.stringValue = "Confirm:"
        confirmLabelField.alignment = .right
        confirmLabelField.font = NSFont.systemFont(ofSize: 12)
        confirmLabelField.textColor = NSColor.black
        self.view.addSubview(confirmLabelField)
        confirmLabelField.snp.makeConstraints{ make in
            make.centerY.equalTo(confirmField)
            make.trailing.equalTo(confirmField.snp.leading).offset(-10)
        }

        hintField.lineBreakMode = .byWordWrapping
        if #available(OSX 10.11, *) {
            hintField.maximumNumberOfLines = 4
        } else {
            // Fallback on earlier versions
        }
        self.view.addSubview(hintField)
        hintField.snp.makeConstraints{ make in
            make.width.equalTo(280)
            make.height.equalTo(40)
            make.top.equalTo(confirmField.snp.bottom).offset(10)
            make.leading.equalTo(140)
        }
        
        hintLabelField.stringValue = "Password Hint:"
        hintLabelField.alignment = .right
        hintLabelField.font = NSFont.systemFont(ofSize: 12)
        hintLabelField.textColor = NSColor.black
        self.view.addSubview(hintLabelField)
        hintLabelField.snp.makeConstraints{ make in
            make.top.equalTo(hintField).offset(4)
            make.trailing.equalTo(hintField.snp.leading).offset(-10)
        }
        
        cancelButton.wantsLayer = true
        cancelButton.bezelStyle = .texturedRounded
        cancelButton.title = "Cancel"
        cancelButton.setAccessibilityLabel("Cancel")
        cancelButton.action = #selector(dismissSheet)
        cancelButton.target = self
        self.view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.leading.equalTo(self.view).offset(20)
            make.bottom.equalTo(self.view).offset(-20)
        }
        
        createButton.wantsLayer = true
        createButton.bezelStyle = .rounded
        createButton.keyEquivalent = "\r"
        createButton.isEnabled = true
        createButton.title = "Change Password"
        createButton.setAccessibilityLabel("Change Password")
        createButton.action = #selector(changePassword)
        createButton.target = self
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.width.equalTo(190)
            make.trailing.equalTo(self.view).offset(-20)
            make.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    func dismissSheet() {
        super.dismissViewController(self)
    }
    
    func changePassword() {
        if currentPasswordField.stringValue != appLock.password {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Password Incorrect"
            alert.informativeText = "The current password is incorrect."
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        } else if passwordField.stringValue == "" {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "The password cannot be blank"
            alert.informativeText = "Your password must contain at least one character."
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        } else if hintField.stringValue == "" {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Please create a hint"
            alert.informativeText = "A password hint is required to help you jog your memory."
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        } else if self.passwordField.stringValue == self.confirmField.stringValue {
            appLock.password = passwordField.stringValue
            appLock.passwordHint = hintField.stringValue
            super.dismissViewController(self)
        } else {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Different password and confirmation"
            alert.informativeText = "Please make sure your password and confirmation match one another."
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }
}
