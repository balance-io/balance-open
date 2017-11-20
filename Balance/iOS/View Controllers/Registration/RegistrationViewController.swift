//
//  RegistrationViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class RegistrationViewController: UIViewController {
    // Private
    private let container = UIView()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = UIColor.white
        textField.keyboardType = .emailAddress
        textField.placeholder = "Email address"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private let passwordConfirmationTextField: UITextField = {
        let textField = UITextField()
        textField.tintColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.placeholder = "Password Confirmation"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(self.registerButtonTapped(_:)))
        
        // Container
        self.view.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        // Email text field
        self.emailTextField.delegate = self
        self.container.addSubview(self.emailTextField)
        
        self.emailTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Password text field
        self.passwordTextField.delegate = self
        self.container.addSubview(self.passwordTextField)
        
        self.passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Password confirmation text field
        self.passwordConfirmationTextField.delegate = self
        self.container.addSubview(self.passwordConfirmationTextField)
        
        self.passwordConfirmationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(10.0)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: Action
    
    @objc private func registerButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case self.emailTextField:
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

