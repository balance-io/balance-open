//
//  UnlockApplicationViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 28/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import LocalAuthentication
import UIKit


internal protocol UnlockApplicationViewControllerDelegate: class {
    func didAuthenticateUser(in controller: UnlockApplicationViewController)
}


internal final class UnlockApplicationViewController: UIViewController {
    // Internal
    internal weak var delegate: UnlockApplicationViewControllerDelegate?
    
    // Private
    private let authenticateContext = LAContext()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please unlock the app to continue"
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.Balance.font(ofSize: 25.0, weight: .semibold)
        
        return label
    }()
    
    private let retryAuthenticationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.Balance.font(ofSize: 16.0, weight: .regular)
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 4.0
        
        return button
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // Title label
        self.view.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        // Retry button
        self.retryAuthenticationButton.addTarget(self, action: #selector(self.retryAuthenticationButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(self.retryAuthenticationButton)
        
        self.retryAuthenticationButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            
            make.height.equalTo(50.0)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.presentAuthenticationAlert()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Presentation
    
    private func presentAuthenticationAlert() {
        self.retryAuthenticationButton.isHidden = true
        self.titleLabel.isHidden = true
        
        self.authenticateContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Access Balance") { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.delegate?.didAuthenticateUser(in: self)
                } else {
                    self.retryAuthenticationButton.isHidden = false
                    self.titleLabel.isHidden = false
                }
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func retryAuthenticationButtonTapped(_ sender: Any) {
        self.presentAuthenticationAlert()
    }
}

