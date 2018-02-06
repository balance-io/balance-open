//
//  UnlockApplicationViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 28/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import LocalAuthentication
import UIKit

protocol UnlockApplicationViewControllerDelegate: class {
    func didAuthenticateUser(in controller: UnlockApplicationViewController)
}

final class UnlockApplicationViewController: UIViewController {
    weak var delegate: UnlockApplicationViewControllerDelegate?
    
    private let authenticateContext = LAContext()
    
    private let titleLabel = UILabel()
    private let retryAuthenticationButton = UIButton(type: .system)
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // Title label
        titleLabel.text = "Please unlock the app to continue"
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 25.0, weight: .semibold)
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        // Retry button
        retryAuthenticationButton.backgroundColor = UIColor.white
        retryAuthenticationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        retryAuthenticationButton.setTitle("Retry", for: .normal)
        retryAuthenticationButton.setTitleColor(UIColor.black, for: .normal)
        retryAuthenticationButton.layer.cornerRadius = 4.0
        retryAuthenticationButton.addTarget(self, action: #selector(retryAuthenticationButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(retryAuthenticationButton)
        retryAuthenticationButton.snp.makeConstraints { make in
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
        presentAuthenticationAlert()
    }
    
    // MARK: Presentation
    
    private func presentAuthenticationAlert() {
        retryAuthenticationButton.isHidden = true
        titleLabel.isHidden = true
        
        authenticateContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Access Balance") { success, error in
            async {
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
        presentAuthenticationAlert()
    }
}
