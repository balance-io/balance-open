//
//  BitfinexCredentials.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Private global function so we can call it from init
fileprivate func keychainIdentifier(_ identifier: String) -> String {
    return "com.BitfinexAPIClient.Credentials.\(identifier)"
}

internal extension BitfinexAPIClient {
    internal struct Credentials: APICredentials {
        // Internal
        let components: APICredentialsComponents
        let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA384)
        let hmacAlgorithmDigestLength = Int(CC_SHA384_DIGEST_LENGTH)
        
        // Private
        private let secretKeyData: Data

        // MARK: Initialization
        
        init(key: String, secret: String) throws {
            let components = try APICredentialsComponents(key: key, secret: secret, passphrase: nil)
            try self.init(component: components)
        }
        
        init(component: APICredentialsComponents) throws {
            guard let secretData = component.secret.data(using: .utf8) else {
                throw APICredentialsComponents.Error.invalidSecret(message: "Unable to turn secret into Data")
            }
            
            self.secretKeyData = secretData
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
                throw APICredentialsComponents.Error.dataNotReachable
            }
            
            try self.init(component: unwrapedComponents)
            
            try save(identifier: identifier)
            if updatedCredentials {
                keychain[oldNamespacedIdentifier].clear()
            }
        }
        
        // MARK: Signature
        
        func generateSignature(date: Date, requestPath: String, body: Data?) throws -> String {
            // Turn body into JSON string
            let bodyString: String
            if let body = body, let dataString = String(data: body, encoding: .utf8) {
                bodyString = dataString
            } else {
                bodyString = ""
            }
            
            // Message
            let message = "/api/\(requestPath)\(date.timeIntervalSince1970)\(bodyString)"
            guard let messageData = message.data(using: .utf8) else {
                throw APICredentialsComponents.Error.standard(message: "Unable to turn message string into Data")
            }
            
            let signature = self.createSignatureData(with: messageData, secretKeyData: self.secretKeyData).reduce("") { (result, byte) -> String in
                return result + String(format: "%02x", byte)
            }

            return signature
        }
        
        // MARK: Keychain
        
        func namespacedKeychainIdentifier(_ identifier: String) -> String {
            return keychainIdentifier(identifier)
        }
    }
}
