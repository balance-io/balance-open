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
    private let headerImageView = UIImageView(image: UIImage(named: "intro-logo"))
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.Balance.font(ofSize: 30.0, weight: .semibold)
        label.text = "Balance"
        
        return label
    }()
    
    private let headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 0.75)
        label.font = UIFont.Balance.font(ofSize: 15.0, weight: .regular)
        label.text = "A wallet for all the world's currencies"
        
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.tintColor = UIColor.white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 4.0
        
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.tintColor = UIColor.white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 4.0
        
        return button
    }()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // Navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Header title
        self.view.addSubview(self.headerLabel)
        
        self.headerLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        // Subtitle label
        self.view.addSubview(self.headerSubtitleLabel)
        
        self.headerSubtitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.headerLabel.snp.bottom)
        }
        
        // Header image view
        self.view.addSubview(self.headerImageView)
        
        self.headerImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.headerLabel.snp.top).offset(-10.0)
        }
        
        // Register button
        self.registerButton.addTarget(self, action: #selector(self.registerButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(self.registerButton)
        
        self.registerButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(44.0)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10.0)
        }
        
        // Login button
        self.loginButton.addTarget(self, action: #selector(self.loginButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(self.loginButton)
        
        self.loginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(44.0)
            make.bottom.equalTo(self.registerButton.snp.top).offset(-10.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
