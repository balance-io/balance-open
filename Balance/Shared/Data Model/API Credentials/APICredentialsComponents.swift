//
//  APICredentialsComponents.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal struct APICredentialsComponents
{
    // Internal
    internal let key: String
    internal let secret: String
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
        self.key = key
        self.secret = secret
        self.passphrase = passphrase
    }
    
    internal init(identifier: String) throws
    {
        guard let key = keychain[identifier, "key"], let secret = keychain[identifier, "secret"] else {
            throw Error.dataNotFound(identifier: identifier)
        }

        let passphrase = keychain[identifier, "passphrase"]
        try self.init(key: key, secret: secret, passphrase: passphrase)
    }
}
