//
//  Credentials.swift
//  BalanceOpen
//
//  Created by Red Davis on 27/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Private global function so we can call it from init
fileprivate func keychainIdentifier(_ identifier: String) -> String {
    return "com.GDAXAPIClient.Credentials.\(identifier)"
}

extension GDAXAPIClient {
    struct Credentials: APICredentials {
        // Internal
        let components: APICredentialsComponents
        let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        let hmacAlgorithmDigestLength = Int(CC_SHA256_DIGEST_LENGTH)
        
        // Private
        private let secretKeyData: Data
        
        // MARK: Initialization
        
        init(key: String, secret: String, passphrase: String) throws {
            let components = try APICredentialsComponents(key: key, secret: secret, passphrase: passphrase)
            try self.init(component: components)
        }
        
        init(component: APICredentialsComponents) throws {
            guard let decodedSecretData = Data(base64Encoded: component.secret) else
            {
                throw APICredentialsComponents.Error.invalidSecret(message: "Secret is not base64 encoded")
            }
            
            self.secretKeyData = decodedSecretData
            self.components = component
        }
        
        init(identifier: String) throws {
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
        
        func generateSignature(timestamp: Date, requestPath: String, body: Data?, method: String) throws -> String {
            // Turn body into JSON string
            let bodyString: String
            if let body = body, let dataString = String(data: body, encoding: .utf8) {
                bodyString = dataString
            } else {
                bodyString = ""
            }

            // Message
            let message = "\(timestamp.timeIntervalSince1970)\(method)\(requestPath)\(bodyString)"
            guard let messageData = message.data(using: .utf8) else {
                throw APICredentialsComponents.Error.standard(message: "Unable to turn message string into Data")
            }
            
            let signatureData = self.createSignatureData(with: messageData, secretKeyData: self.secretKeyData)
            return signatureData.base64EncodedString()
        }
        
        // MARK: Keychain
        
        func namespacedKeychainIdentifier(_ identifier: String) -> String {
            return keychainIdentifier(identifier)
        }
    }
}
