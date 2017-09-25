//
//  BitfinexCredentials.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith


internal extension BitfinexAPIClient
{
    internal struct Credentials: APICredentials
    {
        // Internal
        internal let components: APICredentialsComponents
        internal let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA384)
        internal let hmacAlgorithmDigestLength = Int(CC_SHA384_DIGEST_LENGTH)
        
        // Private
        private let secretKeyData: Data

        // MARK: Initialization
        
        internal init(key: String, secret: String) throws
        {
            let components = try APICredentialsComponents(key: key, secret: secret, passphrase: nil)
            try self.init(component: components)
        }
        
        internal init(component: APICredentialsComponents) throws
        {
            guard let secretData = component.secret.data(using: .utf8) else
            {
                throw APICredentialsComponents.Error.invalidSecret(message: "Unable to turn secret into Data")
            }
            
            self.secretKeyData = secretData
            self.components = component
        }
        
        internal init(identifier: String) throws
        {
            // :( Unable to use the namespacing function (self.namespacedKeychainIdentifier())
            // as we can't call self before intialization, making this brital.
            // There are tests to catch this being an issue though.
            let namespacedIdentifier = "com.BitfinexAPIClient.Credentials.\(identifier)"
            let components = try APICredentialsComponents(identifier: namespacedIdentifier)
            
            try self.init(component: components)
        }
        
        // MARK: Signature
        
        internal func generateSignature(date: Date, requestPath: String, body: Data?) throws -> String
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
            let message = "/api/\(requestPath)\(date.timeIntervalSince1970)\(bodyString)"
            
            let signature = self.createSignatureData(with: message, secretKeyData: self.secretKeyData).reduce("") { (result, byte) -> String in
                return result + String(format: "%02x", byte)
            }

            return signature
        }
        
        // MARK: Keychain
        
        func namespacedKeychainIdentifier(_ identifier: String) -> String
        {
            return "com.BitfinexAPIClient.Credentials.\(identifier)"
        }
    }
}
