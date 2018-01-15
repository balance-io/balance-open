//
//  KrakenCredentials.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Private global function so we can call it from init
fileprivate func keychainIdentifier(_ identifier: String) -> String {
    return "com.KrakenAPIClient.Credentials.\(identifier)"
}

extension KrakenAPIClient {
    struct Credentials: APICredentials {
        // Internal
        let components: APICredentialsComponents
        let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA512)
        let hmacAlgorithmDigestLength = Int(CC_SHA512_DIGEST_LENGTH)
        
        // Private
        private let secretKeyData: Data
        
        // MARK: Initialization
        
        init(key: String, secret: String) throws {
            let components = try APICredentialsComponents(key: key, secret: secret, passphrase: nil)
            try self.init(component: components)
        }
        
        init(component: APICredentialsComponents) throws {
            guard let decodedSecretData = Data(base64Encoded: component.secret) else {
                throw APICredentialsComponents.Error.invalidSecret(message: "Secret is not base64 encoded")
            }
            
            self.secretKeyData = decodedSecretData
            self.components = component
        }
        
        internal init(identifier: String) throws {
            var updatedCredentials = false
            let namespacedIdentifier = keychainIdentifier(identifier)
            let oldNamespacedIdentifier = keychainIdentifier("main")
            var components = try? APICredentialsComponents(identifier: namespacedIdentifier)
            if components == nil {
                components = try? APICredentialsComponents(identifier: oldNamespacedIdentifier)
                updatedCredentials = true
            }
            
            guard let unwrapedComponents = components else {
                throw APICredentialsComponents.Error.dataNotFound(identifier: identifier)
            }
            
            try self.init(component: unwrapedComponents)
            
            // If the fetching of the old credentials succeeds, save the new ones and delete the old ones
            if updatedCredentials {
                try save(identifier: identifier)
                keychain[oldNamespacedIdentifier].clear()
            }
        }
        
        // MARK: Signature
        
        func generateSignature(nonce: String, requestPath: String, body: String) throws -> String {
            // sha256(nonce + body data)
            guard let sha256NonceBody = (nonce + body).sha256() else {
                throw APICredentialsError.creatingSignature(message: "SHA256 failed")
            }
            
            // Message
            let requestPathData = requestPath.data(using: .utf8)!
            let message = requestPathData + sha256NonceBody

            return self.createSignatureData(with: message, secretKeyData: self.secretKeyData).base64EncodedString()
        }
        
        // MARK: Keychain
        
        func namespacedKeychainIdentifier(_ identifier: String) -> String {
            return keychainIdentifier(identifier)
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
