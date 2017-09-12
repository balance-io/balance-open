//
//  Credentials.swift
//  BalanceOpen
//
//  Created by Red Davis on 27/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith


internal extension GDAXAPIClient
{
    internal struct Credentials: APICredentials
    {
        // Internal
        internal let components: APICredentialsComponents
        internal let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        
        // Private
        private let secretKeyData: Data
        
        // MARK: Initialization
        
        internal init(key: String, secret: String, passphrase: String) throws
        {
            let components = try APICredentialsComponents(key: key, secret: secret, passphrase: passphrase)
            try self.init(component: components)
        }
        
        internal init(component: APICredentialsComponents) throws
        {
            guard let decodedSecretData = Data(base64Encoded: component.secret) else
            {
                throw APICredentialsComponents.Error.invalidSecret(message: "Secret is not base64 encoded")
            }
            
            self.secretKeyData = decodedSecretData
            self.components = component
        }
        
        internal init(identifier: String) throws
        {
            // :( Unable to use the namespacing function (self.namespacedKeychainIdentifier())
            // as we can't call self before intialization, making this brital.
            // There are tests to catch this being an issue though.
            let namespacedIdentifier = "com.GDAXAPIClient.Credentials.\(identifier)"
            let components = try APICredentialsComponents(identifier: namespacedIdentifier)
            
            try self.init(component: components)
        }
        
        // MARK: Signature
        
        internal func generateSignature(timestamp: Date, requestPath: String, body: Data?, method: String) throws -> String
        {
            // Turn body into JSON string
            let bodyString: String
            if let unwrappedBody = body,
               let dataString = String(data: unwrappedBody, encoding: .utf8)
            {
                bodyString = dataString
            }
            else
            {
                bodyString = ""
            }

            // Message
            let message = "\(timestamp.timeIntervalSince1970)\(method)\(requestPath)\(bodyString)"
            return self.createSignature(with: message)
        }
        
        // MARK: Keychain
        
        internal func namespacedKeychainIdentifier(_ identifier: String) -> String
        {
            return "com.GDAXAPIClient.Credentials.\(identifier)"
        }
    }
}
