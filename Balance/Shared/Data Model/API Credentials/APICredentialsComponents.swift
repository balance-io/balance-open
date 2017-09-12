//
//  APICredentialsComponents.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith


internal struct APICredentialsComponents
{
    // Internal
    internal let key: String
    internal let secret: String
    internal let decodedSecretData: Data
    internal let passphrase: String?
    
    internal var dictionary: [String : Any] {
        var dictionary: [String : Any] = [
            "key" : self.key,
            "secret" : self.secret
        ]
        
        if let unwrappedPassphrase = self.passphrase
        {
            dictionary["passphrase"] = unwrappedPassphrase
        }
        
        return dictionary
    }
    
    // MARK: Initialization
    
    internal init(key: String, secret: String, passphrase: String?) throws
    {
        guard let decodedSecretData = Data(base64Encoded: secret) else
        {
            throw Error.invalidSecret(message: "Secret is not base64 encoded")
        }
        
        self.key = key
        self.secret = secret
        self.decodedSecretData = decodedSecretData
        self.passphrase = passphrase
    }
    
    internal init(identifier: String) throws
    {
        guard let data = Locksmith.loadDataForUserAccount(userAccount: identifier),
            let key = data["key"] as? String,
            let secret = data["secret"] as? String else
        {
            throw Error.dataNotFound(identifier: identifier)
        }
        
        let passphrase = data["passphrase"] as? String
        try self.init(key: key, secret: secret, passphrase: passphrase)
    }
}
