//
//  SetPasswordViewController.swift
//  Bal
//
//  Created by Butler on 11/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class SetPasswordViewController: NSViewController {
    
    var completionBlock: (() -> Void)?
    
    let passwordLabelField = LabelField()
    let passwordField = NSSecureTextField()
    let confirmLabelField = LabelField()
    let confirmField = NSSecureTextField()
    let hintLabelField = LabelField()
    let hintField = TextField()
    
    let cancelButton = Button()
    let createButton = Button()
    
    init(completionBlock: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.completionBlock = completionBlock
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
            make.width.equalTo(400)
            make.height.equalTo(190)
        }
        
        self.view.addSubview(passwordField)
        passwordField.snp.makeConstraints{ make in
            make.width.equalTo(260)
            make.top.equalTo(self.view).offset(20)
            make.leading.equalTo(120)
        }
        
        passwordLabelField.stringValue = "Password:"
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
            make.width.equalTo(260)
            make.top.equalTo(passwordField.snp.bottom).offset(10)
            make.leading.equalTo(120)
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
        
        hintField.placeholderString = "optional"
        hintField.lineBreakMode = .byWordWrapping
        hintField.maximumNumberOfLines = 4
        self.view.addSubview(hintField)
        hintField.snp.makeConstraints{ make in
            make.width.equalTo(260)
            make.height.equalTo(40)
            make.top.equalTo(confirmField.snp.bottom).offset(10)
            make.leading.equalTo(120)
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
        createButton.title = "Create Password"
        createButton.setAccessibilityLabel("Create Password")
        createButton.action = #selector(createPassword)
        createButton.target = self
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.width.equalTo(190)
            make.trailing.equalTo(self.view).offset(-20)
            make.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    @objc func dismissSheet() {
        super.dismissViewController(self)
        completionBlock?()
    }
    
    @objc func createPassword() {
        //TODO Get the alerts to pop up over the main view
        if passwordField.stringValue == "" {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "The password cannot be blank"
            alert.informativeText = "Your password must contain at least one character."
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
//        else if hintField.stringValue == "" {
//            let alert = NSAlert()
//            alert.addButton(withTitle: "OK")
//            alert.messageText = "Please create a hint"
//            alert.informativeText = "A password hint is required to help you jog your memory."
//            alert.alertStyle = .informational
//            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
//        }
        else if passwordField.stringValue == self.confirmField.stringValue {
            appLock.password = passwordField.stringValue
            appLock.passwordHint = hintField.stringValue
            appLock.lockEnabled = true
            dismissSheet()
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
