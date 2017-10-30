//
//  LoginViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class LoginViewController: UIViewController {
    // Private
    private let container = UIView()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .emailAddress
        textField.placeholder = "Email address"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
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
        
        return button
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(self.loginButtonTapped(_:)))
        
        // Container
        self.view.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        // Email text field
        self.container.addSubview(self.emailTextField)
        
        self.emailTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Password text field
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
}

