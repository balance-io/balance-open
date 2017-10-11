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
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(self.registerButtonTapped(_:)))
        
        // Email text field
        self.view.addSubview(self.emailTextField)
        
        self.emailTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.centerY).offset(-5.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        
        // Password text field
        self.view.addSubview(self.passwordTextField)
        
        self.passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.centerY).offset(5.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
    // MARK: Action
    
    @objc private func registerButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
