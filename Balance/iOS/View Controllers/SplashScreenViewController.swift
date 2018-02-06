//
//  SplashScreenViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class SplashScreenViewController: UIViewController {
    private let headerImageView = UIImageView(image: #imageLiteral(resourceName: "intro-logo"))
    private let headerLabel = UILabel()
    private let headerSubtitleLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // Navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Header title
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .semibold)
        headerLabel.text = "Balance"
        self.view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Subtitle label
        headerSubtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.75)
        headerSubtitleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        headerSubtitleLabel.text = "A wallet for all the world's currencies"
        self.view.addSubview(headerSubtitleLabel)
        headerSubtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom)
        }
        
        // Header image view
        self.view.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(headerLabel.snp.top).offset(-10.0)
        }
        
        // Register button
        registerButton.setTitle("Register", for: .normal)
        registerButton.tintColor = UIColor.white
        registerButton.layer.borderColor = UIColor.white.cgColor
        registerButton.layer.borderWidth = 1.0
        registerButton.layer.cornerRadius = 4.0
        registerButton.addTarget(self, action: #selector(registerButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(44.0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10.0)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-10.0)
            }
        }
        
        // Login button
        loginButton.setTitle("Login", for: .normal)
        loginButton.tintColor = UIColor.white
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.cornerRadius = 4.0
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(44.0)
            make.bottom.equalTo(registerButton.snp.top).offset(-10.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
