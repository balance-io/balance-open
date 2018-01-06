//
//  DisablePasswordViewController.swift
//  Bal
//
//  Created by Butler on 11/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class DisablePasswordViewController: NSViewController {
    
    var completionBlock: (() -> Void)?
    
    let currentPasswordLabelField = LabelField()
    let currentPasswordField = SecureField()
    
    let cancelButton = Button()
    let disableButton = Button()
    
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
            make.width.equalTo(440)
            make.height.equalTo(130)
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
            make.left.equalTo(self.view).offset(20)
            make.bottom.equalTo(self.view).offset(-20)
        }
        
        disableButton.wantsLayer = true
        disableButton.bezelStyle = .rounded
        disableButton.keyEquivalent = "\r"
        disableButton.isEnabled = true
        disableButton.title = "Disable Password"
        disableButton.setAccessibilityLabel("Disable Password")
        disableButton.action = #selector(disablePassword)
        disableButton.target = self
        self.view.addSubview(disableButton)
        disableButton.snp.makeConstraints { make in
            make.width.equalTo(190)
            make.right.equalTo(self.view).offset(-20)
            make.bottom.equalTo(self.view).offset(-20)
        }
        
        self.view.addSubview(currentPasswordField)
        currentPasswordField.snp.makeConstraints{ make in
            make.width.equalTo(260)
            make.top.equalTo(self.view).offset(20)
            make.right.equalTo(disableButton)
        }
        
        currentPasswordLabelField.stringValue = "Current Password:"
        currentPasswordLabelField.alignment = .right
        currentPasswordLabelField.font = NSFont.systemFont(ofSize: 12)
        currentPasswordLabelField.textColor = NSColor.black
        self.view.addSubview(currentPasswordLabelField)
        currentPasswordLabelField.snp.makeConstraints{ make in
            make.centerY.equalTo(currentPasswordField)
            make.right.equalTo(currentPasswordField.snp.left).offset(-10)
        }
    }
    
    @objc func dismissSheet() {
        super.dismissViewController(self)
        completionBlock?()
    }
    
    @objc func disablePassword() {
        if currentPasswordField.stringValue == appLock.password {
            appLock.lockEnabled = false
            appLock.password = nil
            dismissSheet()
        } else {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Password Incorrect"
            alert.informativeText = "Please enter the correct password to disable app locking."
            alert.alertStyle = .informational
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }
}
