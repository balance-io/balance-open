//
//  ResetPasswordViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class ResetPasswordViewController: UIViewController {
    // Private
    private let container = UIView()
    
    private let resetCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Reset Code"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "New Password"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private let passwordConfirmationTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Password Confirmation"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        
        return textField
    }()
    
    private var observers = [NSObjectProtocol]()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        // Notifications
        self.registerForNotifications()
        
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
    
    deinit
    {
        self.unregisterFromNotifications()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Container
        self.view.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Content container
        let contentContainer = UIView()
        self.container.addSubview(contentContainer)
        
        contentContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Reset code text field
        self.resetCodeTextField.delegate = self
        contentContainer.addSubview(self.resetCodeTextField)
        
        self.resetCodeTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Password text field
        self.passwordTextField.delegate = self
        contentContainer.addSubview(self.passwordTextField)
        
        self.passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.resetCodeTextField.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Password confirmation text field
        self.passwordConfirmationTextField.delegate = self
        contentContainer.addSubview(self.passwordConfirmationTextField)
        
        self.passwordConfirmationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(10.0)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    // MARK: Action
    
    @objc private func resetButtonTapped(_ sender: Any) {
        // TODO: reset password
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Notifications
    
    private func registerForNotifications()
    {
        var observers = [NSObjectProtocol]()
        
        // Keyboard will show
        let keyboardWillShowNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { [unowned self] (notification) in
            guard let userInfo = notification.userInfo,
                let screenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
                let window = self.view.window else
            {
                return
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationCurve), animations: {
                let keyboardEndFrame = self.view.convert(screenEndFrame, from: window)
                
                self.container.snp.remakeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalTo(self.view.snp.bottom).offset(-keyboardEndFrame.height)
                })
                
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
            })
        }
        
        observers.append(keyboardWillShowNotification)
        
        // Keyboard will hide
        let keyboardWillHideNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [unowned self] (notification) in
            guard let userInfo = notification.userInfo,
                let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt else
            {
                return
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationCurve), animations: {
                self.container.snp.remakeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
                
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
            })
        }
        
        observers.append(keyboardWillHideNotification)
        
        // Text field did change
        let textFieldDidChangeNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nil, queue: nil, using: { [unowned self] (_) in
            guard let resetCode = self.resetCodeTextField.text,
                  resetCode.lengthOfBytes(using: .utf8) > 0,
                  let password = self.passwordTextField.text,
                  password.lengthOfBytes(using: .utf8) > 0,
                  let passwordConfirmation = self.passwordConfirmationTextField.text,
                  passwordConfirmation.lengthOfBytes(using: .utf8) > 0,
                  password == passwordConfirmation else {
                    
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        })
        
        observers.append(textFieldDidChangeNotification)
        
        // Set observers
        self.observers = observers
    }
    
    private func unregisterFromNotifications()
    {
        self.observers.forEach { (observer) in
            NotificationCenter.default.removeObserver(observer)
        }
        
        self.observers.removeAll()
    }
}

// MARK: UITextFieldDelegate

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case self.resetCodeTextField:
            self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            self.passwordConfirmationTextField.becomeFirstResponder()
        case self.passwordConfirmationTextField:()
            // TODO: Trigger API call
        default:()
        }
        
        return true
    }
}
