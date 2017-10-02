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
    
    // Private
    private let source: Source
    private let fieldTypes: [FieldType]
    
    private let gdaxAPIClient = GDAXAPIClient(server: .production)
    private let poloniexAPIClient = PoloniexApi()
    
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
        default:
            self.fieldTypes = []
        }
    }
    
    // MARK: Authenticate
    
    internal func authenticate(_ completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        if !self.isValid
        {
            completionHandler(false, nil)
            return
        }
        
        let loginStrings = self.buildLoginFields()
        switch self.source
        {
        case .gdax:
            self.gdaxAPIClient.authenticationChallenge(loginStrings: loginStrings, closeBlock: { (success, error, _) in
                completionHandler(success, error)
            })
        case .poloniex:
            self.poloniexAPIClient.authenticationChallenge(loginStrings: loginStrings, closeBlock: { (success, error, _) in
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
                field = Field(name: "Passphrase", label: "Passphrase", type: "secrepassphrase", value: self.passphraseKeyTextField.text)
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
        }
    }
    
    internal func title(at index: Int) -> String
    {
        let type = self.fieldTypes[index]
        return type.title()
    }
}

// MARK: FieldType

fileprivate extension NewAccountViewModel
{
    fileprivate enum FieldType
    {
        case key
        case secretKey
        case passphrase
        
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
            }
        }
    }
}
