//
//  SplashScreenViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class SplashScreenViewController: UIViewController {
    // Private
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        
        return button
    }()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Register button
        self.registerButton.addTarget(self, action: #selector(self.registerButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(self.registerButton)
        
        self.registerButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10.0)
        }
        
        // Login button
        self.loginButton.addTarget(self, action: #selector(self.loginButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(self.loginButton)
        
        self.loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.registerButton.snp.top).offset(-10.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @objc private func loginButtonTapped(_ sender: Any) {
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc private func registerButtonTapped(_ sender: Any) {
        let registrationViewController = RegistrationViewController()
        self.navigationController?.pushViewController(registrationViewController, animated: true)
    }
}
