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
    internal struct Credentials
    {
        // Internal
        internal let key: String
        internal let secret: String
        internal let passphrase: String
        
        // Private
        private let decodedSecretData: Data
        
        private var dictionary: [String : Any] {
            return [
                "key" : self.key,
                "secret" : self.secret,
                "passphrase" : self.passphrase
            ]
        }
        
        // MARK: Initialization
        
        internal init(key: String, secret: String, passphrase: String) throws
        {
            guard let decodedSecretData = Data(base64Encoded: secret) else
            {
                throw CredentialsError.invalidSecret(message: "Secret is not base64 encoded")
            }
            
            self.key = key
            self.secret = secret
            self.passphrase = passphrase
            self.decodedSecretData = decodedSecretData
        }
        
        internal init(identifier: String) throws
        {
            // :( Unable to use namespacing function as we can't call self before
            // intialization, making this brital. There are tests to catch this
            // being an issue though.
            let namespacedIdentifier = "com.GDAXAPIClient.Credentials.\(identifier)"
            guard let data = Locksmith.loadDataForUserAccount(userAccount: namespacedIdentifier),
                  let key = data["key"] as? String,
                  let secret = data["secret"] as? String,
                  let passphrase = data["passphrase"] as? String else
            {
                throw CredentialsError.dataNotFound(identifier: identifier)
            }
            
            try self.init(key: key, secret: secret, passphrase: passphrase)
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
            guard let messageData = message.data(using: .utf8) else
            {
                fatalError()
            }
            
            // Create the signature
            let signatureCapacity = Int(CC_SHA256_DIGEST_LENGTH)
            let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: signatureCapacity)
            defer
            {
                signature.deallocate(capacity: signatureCapacity)
            }
            
            self.decodedSecretData.withUnsafeBytes({ (secretBytes: UnsafePointer<UInt8>) -> Void in
                messageData.withUnsafeBytes({ (messageBytes: UnsafePointer<UInt8>) -> Void in
                    let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
                    CCHmac(algorithm, secretBytes, self.decodedSecretData.count, messageBytes, messageData.count, signature)
                })
            })
            
            let signatureData = Data(bytes: signature, count: signatureCapacity)
            return signatureData.base64EncodedString()
        }
        
        // MARK: Save
        
        internal func save(identifier: String) throws
        {
            let namespacedIdentifier = self.namespacedKeychainIdentifier(identifier)
            
            do
            {
                try Locksmith.saveData(data: self.dictionary, forUserAccount: namespacedIdentifier)
            }
            catch LocksmithError.duplicate
            {
                try Locksmith.updateData(data: self.dictionary, forUserAccount: namespacedIdentifier)
            }
            catch let error
            {
                throw error
            }
        }
        
        // MARK: Keychain
        
        private func namespacedKeychainIdentifier(_ identifier: String) -> String
        {
            return "com.GDAXAPIClient.Credentials.\(identifier)"
        }
    }
}
