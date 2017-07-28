//
//  GDAXAuthViewController.swift
//  BalanceOpen
//
//  Created by Red Davis on 28/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Cocoa


internal protocol GDAXAuthViewControllerDelegate: class
{
    func didSuccessfullyLogin(with credentials: GDAXAPIClient.Credentials, in controller: GDAXAuthViewController)
}


internal final class GDAXAuthViewController: NSViewController
{
    // Internal
    internal weak var delegate: GDAXAuthViewControllerDelegate?
    
    // Private
    private let apiClient = GDAXAPIClient(server: .sandbox)
    
    private let keyTextField = TextField(frame: NSRect.zero)
    private let secretTextField = TextField(frame: NSRect.zero)
    private let passphraseTextField = TextField(frame: NSRect.zero)
    
    private let loginButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.bezelStyle = .rounded
        button.title = "Login"
        
        return button
    }()
    
    private let progressIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.isHidden = true
        
        return indicator
    }()
    
    private var isLoggingIn = false {
        didSet
        {
            self.loginButton.isHidden = self.isLoggingIn
            self.progressIndicator.isHidden = self.isLoggingIn
            
            self.keyTextField.isEditable = !self.isLoggingIn
            self.secretTextField.isEditable = !self.isLoggingIn
            self.passphraseTextField.isEditable = !self.isLoggingIn
            
            if self.isLoggingIn
            {
                self.progressIndicator.startAnimation(nil)
            }
            else
            {
                self.progressIndicator.stopAnimation(nil)
            }
        }
    }
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        self.title = "GDAX Login"
    }
    
    internal required init?(coder: NSCoder)
    {
        abort()
    }
    
    // MARK: View lifecycle
    
    override func loadView()
    {
        self.view = NSView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 500.0, height: 500.0)))
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Container
        let container = NSView()
        self.view.addSubview(container)
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }
        
        // Key text field
        self.keyTextField.placeholderString = "Key"
        container.addSubview(self.keyTextField)
        
        self.keyTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Secret text field
        self.secretTextField.placeholderString = "Secret"
        container.addSubview(self.secretTextField)
        
        self.secretTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.keyTextField.snp.bottom).offset(5.0)
            make.width.equalToSuperview()
        }
        
        // Passphrase text field
        self.passphraseTextField.placeholderString = "Passphrase"
        container.addSubview(self.passphraseTextField)
        
        self.passphraseTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.secretTextField.snp.bottom).offset(5.0)
            make.width.equalToSuperview()
        }
        
        // Login button
        self.loginButton.set(target: self, action: #selector(self.loginButtonClicked(_:)))
        container.addSubview(self.loginButton)
        
        self.loginButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(self.passphraseTextField.snp.bottom).offset(15.0)
        }
        
        // Progress indicator
        container.addSubview(self.progressIndicator)
        
        self.progressIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(self.loginButton)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc private func loginButtonClicked(_ sender: Any)
    {
        self.isLoggingIn = true
        
        do
        {
            let credentials = try GDAXAPIClient.Credentials(key: self.keyTextField.stringValue, secret: self.secretTextField.stringValue, passphrase: self.passphraseTextField.stringValue)
            
            self.apiClient.credentials = credentials
            self.apiClient.fetchAccounts({ [unowned self] (_, error) in
                guard let unwrappedError = error else
                {
                    self.delegate?.didSuccessfullyLogin(with: credentials, in: self)
                    return
                }
                
                // TODO: Display error
                print(unwrappedError)
            })
        }
        catch GDAXAPIClient.CredentialsError.invalidSecret
        {
            // TODO: show alert
        }
        catch { }
    }
}
