//
//  LoginViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import OnePasswordExtension
import UIKit


internal final class LoginViewController: UIViewController {
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
    
    private let forgottonPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgotton Password", for: .normal)
        button.tintColor = UIColor.white
        
        return button
    }()
    
    private let onePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        
        let onePasswordBundle = Bundle(for: OnePasswordExtension.self)
        button.setImage(UIImage(named: "onepassword-button-light", in: onePasswordBundle, compatibleWith: nil), for: .normal)
        
        return button
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(self.loginButtonTapped(_:)))
        
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
        
        // 1Password button
        self.onePasswordButton.addTarget(self, action: #selector(self.onePasswordButtonTapped(_:)), for: .touchUpInside)
        
        self.onePasswordButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30.0, height: 30.0))
        }
        
        // Password text field
        self.passwordTextField.rightView = self.onePasswordButton
        self.passwordTextField.rightViewMode = OnePasswordExtension.shared().isAppExtensionAvailable() ? .always : .never
        self.passwordTextField.delegate = self
        self.container.addSubview(self.passwordTextField)
        
        self.passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Forgotton password
        self.forgottonPasswordButton.addTarget(self, action: #selector(self.forgottonPasswordButtonTapped(_:)), for: .touchUpInside)
        self.container.addSubview(self.forgottonPasswordButton)
        
        self.forgottonPasswordButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(10.0)
            make.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: Action
    
    @objc private func loginButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func forgottonPasswordButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Forgotton Password", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = self.emailTextField.text
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Reset password action
        let resetPasswordAction = UIAlertAction(title: "Reset Password", style: .default) { (_) in
//            guard let textField = alertController.textFields?.first else {
//                return
//            }
            // TODO: -
        }
        alertController.addAction(resetPasswordAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func onePasswordButtonTapped(_ sender: Any) {
        OnePasswordExtension.shared().findLogin(forURLString: "https://balancemy.money", for: self, sender: sender) { (results, error) in
            guard let unwrappedResults = results else
            {
                return
            }
            
            self.emailTextField.text = unwrappedResults[AppExtensionUsernameKey] as? String
            self.passwordTextField.text = unwrappedResults[AppExtensionPasswordKey] as? String
        }
    }
}

// MARK: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:()
            // TODO: Trigger API call
        default:()
        }
        
        return true
    }
}

