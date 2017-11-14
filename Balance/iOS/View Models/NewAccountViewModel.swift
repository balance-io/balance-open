//
//  NewAccountViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 02/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class NewAccountViewModel
{
    // Internal
    internal var numberOfTextFields: Int {
        return self.fieldTypes.count
    }
    
    internal var isValid: Bool {
        for index in 0..<self.fieldTypes.count
        {
            let textField = self.textField(at: index)
            guard let text = textField.text,
                  text.lengthOfBytes(using: .utf8) > 0 else
            {
                return false
            }
        }

        return true
    }
    
    internal var loginWithQRCodeSupported: Bool {
        switch self.source
        {
        case .bitfinex, .kraken:
            return true
        default:
            return false
        }
    }
    
    // Private
    private let source: Source
    private let fieldTypes: [FieldType]
    
    private let gdaxAPIClient = GDAXAPIClient(server: .production)
    private let poloniexAPIClient = PoloniexApi()
    private let bitfinexAPIClient = BitfinexAPIClient()
    private let krakenAPIClient = KrakenAPIClient()
    private let ethplorerAPIClient = EthplorerApi()
    
    private let apiKeyTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.placeholder = "00m70v500d..."
        
        return textField
    }()
    
    private let passphraseKeyTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.placeholder = "balanceisawesome"
        
        return textField
    }()
    
    private let secretKeyKeyTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.placeholder = "4WEijVgdII..."
        
        return textField
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .words
        textField.textAlignment = .right
        textField.placeholder = "Main Wallet"
        
        return textField
    }()
    
    private let addressTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.placeholder = "0x6e11086B4559e0740195b7C4ecFA32ed16a8a90D"
        
        return textField
    }()
    
    // MARK: Initialization
    
    internal init(source: Source)
    {
        self.source = source
        
        switch source
        {
        case .gdax:
            self.fieldTypes = [.key, .secretKey, .passphrase]
        case .poloniex:
            self.fieldTypes = [.key, .secretKey]
        case .kraken:
            self.fieldTypes = [.key, .secretKey]
        case .bitfinex:
            self.fieldTypes = [.key, .secretKey]
        case .ethplorer:
            self.fieldTypes = [.name, .address]
        default:
            self.fieldTypes = []
        }
    }
    
    // MARK: Authenticate
    
    internal func authenticate(_ completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        if !self.isValid
        {
            completionHandler(false, nil)
            return
        }
        
        let loginFields = self.buildLoginFields()
        self.authenticate(with: loginFields, completionHandler: completionHandler)
    }
    
    internal func authenticate(with fields: [Field], completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        switch self.source
        {
        case .gdax:
            self.gdaxAPIClient.authenticationChallenge(loginStrings: fields, closeBlock: { (success, error, _) in
                completionHandler(success, error)
            })
        case .poloniex:
            self.poloniexAPIClient.authenticationChallenge(loginStrings: fields, closeBlock: { (success, error, _) in
                completionHandler(success, error)
            })
        case .bitfinex:
            self.bitfinexAPIClient.authenticationChallenge(loginStrings: fields, closeBlock: { (success, error, _) in
                completionHandler(success, error)
            })
        case .kraken:
            self.krakenAPIClient.authenticationChallenge(loginStrings: fields, closeBlock: { (success, error, _) in
                completionHandler(success, error)
            })
        case .ethplorer:
            self.ethplorerAPIClient.authenticationChallenge(loginStrings: fields, closeBlock: { (success, error, _) in
                completionHandler(success, error)
            })
        default:
            completionHandler(false, nil)
        }
    }
    
    private func buildLoginFields() -> [Field]
    {
        var fields = [Field]()
        for type in self.fieldTypes
        {
            let field: Field
            switch type
            {
            case .key:
                field = Field(name: "Key", label: "Key", type: "key", value: self.apiKeyTextField.text)
            case .secretKey:
                field = Field(name: "Secret", label: "Secret", type: "secret", value: self.secretKeyKeyTextField.text)
            case .passphrase:
                field = Field(name: "Passphrase", label: "Passphrase", type: "passphrase", value: self.passphraseKeyTextField.text)
            case .name:
                field = Field(name: "Name", label: "Name", type: "name", value: self.nameTextField.text)
            case .address:
                field = Field(name: "Address", label: "Address", type: "address", value: self.addressTextField.text)
            }
            
            fields.append(field)
        }
        
        return fields
    }
    
    // MARK: Table data
    
    internal func textField(at index: Int) -> UITextField
    {
        let type = self.fieldTypes[index]
        
        switch type
        {
        case .key:
            return self.apiKeyTextField
        case .passphrase:
            return self.passphraseKeyTextField
        case .secretKey:
            return self.secretKeyKeyTextField
        case .name:
            return self.nameTextField
        case .address:
            return self.addressTextField
        }
    }
    
    internal func title(at index: Int) -> String
    {
        let type = self.fieldTypes[index]
        return type.title()
    }
}

// MARK: FieldType

internal extension NewAccountViewModel
{
    internal enum FieldType
    {
        case key
        case secretKey
        case passphrase
        case name
        case address
        
        // MARK: Description
        
        internal func title() -> String
        {
            switch self
            {
            case .key:
                return "Key"
            case .secretKey:
                return "Secret"
            case .passphrase:
                return "Passphrase"
            case .name:
                return "Name"
            case .address:
                return "Address"
            }
        }
    }
}
