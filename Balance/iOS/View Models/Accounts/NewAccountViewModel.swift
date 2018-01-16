//
//  NewAccountViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 02/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


final class NewAccountViewModel {
    // Internal
    var numberOfTextFields: Int {
        return self.fields.count
    }
    
    var isValid: Bool {
        for index in 0 ..< fields.count {
            let textField = self.textField(at: index)
            guard let text = textField.text, text.lengthOfBytes(using: .utf8) > 0 else {
                return false
            }
        }

        return true
    }
    
    func mapFieldsData() -> [Field] {
        var newFields = [Field]()
        for index in 0 ..< fields.count {
            let textField = self.textField(at: index)
            var sourceField = fields[index]
            sourceField.value = textField.text
            newFields.append(sourceField)
        }
        return newFields
    }
    
    var loginWithQRCodeSupported: Bool {
        switch self.source {
        case .bitfinex, .kraken:
            return true
        default:
            return false
        }
    }
    
    var existingInstitutionId: Int? {
        return existingInstitution?.institutionId
    }
    
    // Private
    let source: Source
    private let existingInstitution: Institution?
    private let fields: [Field]
    
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
    
    func testValue(at index: Int) -> String {
        let type = fields[index].type
        
        switch type {
        case .key:
            return ""
        case .secret:
            return ""
        case .address:
            return ""
        default:
            return ""
        }
    }
    
    // MARK: Initialization
    
    internal init(source: Source, existingInstitution: Institution?)
    {
        self.source = source
        self.existingInstitution = existingInstitution
        self.fields = source.apiInstitution.fields
    }
    
    // MARK: Authenticate
    
    internal func authenticate(_ completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard isValid else {
            completionHandler(false, nil)
            return
        }
        let loginFields = mapFieldsData()
        self.authenticate(with: loginFields, completionHandler: completionHandler)
    }
    
    internal func authenticate(with fields: [Field], completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        switch self.source {
        case .gdax:
            self.gdaxAPIClient.authenticationChallenge(loginStrings: fields, existingInstitution: existingInstitution) { (success, error, _) in
                completionHandler(success, error)
            }
        case .poloniex:
            self.poloniexAPIClient.authenticationChallenge(loginStrings: fields, existingInstitution: existingInstitution) { (success, error, _) in
                completionHandler(success, error)
            }
        case .bitfinex:
            self.bitfinexAPIClient.authenticationChallenge(loginStrings: fields, existingInstitution: existingInstitution) { (success, error, _) in
                completionHandler(success, error)
            }
        case .kraken:
            self.krakenAPIClient.authenticationChallenge(loginStrings: fields, existingInstitution: existingInstitution) { (success, error, _) in
                completionHandler(success, error)
            }
        case .ethplorer:
            self.ethplorerAPIClient.authenticationChallenge(loginStrings: fields, existingInstitution: existingInstitution) { (success, error, _) in
                completionHandler(success, error)
            }
        default:
            completionHandler(false, nil)
        }
    }
    
    
    // MARK: Table data
    
    func textField(at index: Int) -> UITextField {
        switch fields[index].type {
        case .key:        return apiKeyTextField
        case .passphrase: return passphraseKeyTextField
        case .secret:     return secretKeyKeyTextField
        case .name:       return nameTextField
        case .address:    return addressTextField
        }
    }
    
    func title(at index: Int) -> String {
        let field = fields[index]
        return field.name
    }
    
    func testValue(at index: Int) -> String? {
        let field = fields[index]
        return field.testValue
    }
}
