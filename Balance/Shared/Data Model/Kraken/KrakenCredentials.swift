//
//  KrakenCredentials.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal extension KrakenAPIClient
{
    internal struct Credentials: APICredentials
    {
        // Internal
        internal let components: APICredentialsComponents
        internal let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA512)
        internal let hmacAlgorithmDigestLength = Int(CC_SHA512_DIGEST_LENGTH)
        
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
            let namespacedIdentifier = "com.KrakenAPIClient.Credentials.\(identifier)"
            let components = try APICredentialsComponents(identifier: namespacedIdentifier)
            
            try self.init(component: components)
        }
        
        // MARK: Signature
        
        internal func generateSignature(nonce: String, requestPath: String, body: String) throws -> String
        {
            // sha256(nonce + body data)
            guard let sha256NonceBody = (nonce + body).sha256() else
            {
                throw APICredentialsError.creatingSignature(message: "SHA256 failed")
            }
            
            // Message
            let requestPathData = requestPath.data(using: .utf8)!
            let message = requestPathData + sha256NonceBody

            return self.createSignatureData(with: message, secretKeyData: self.secretKeyData).base64EncodedString()
        }
        
        // MARK: Keychain
        
        func namespacedKeychainIdentifier(_ identifier: String) -> String
        {
            return "com.KrakenAPIClient.Credentials.\(identifier)"
        }
    }
}


// MARK: String+SHA256

fileprivate extension String {
    fileprivate func sha256() -> Data? {
        guard let selfData = self.data(using: .utf8) else {
            return nil
        }
        
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes { bytes in
            selfData.withUnsafeBytes({ selfBytes in
                CC_SHA256(selfBytes, UInt32(selfData.count), bytes)
            })
        }
        
        return digestData
    }
}
