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
        
        // MARK: Signature
        
        internal func generateSignature(timestamp: Date, requestPath: String, body: [String : Any]?, method: String) throws -> String
        {
            // Turn body into JSON string
            let bodyString: String
            if let unwrappedBody = body
            {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: unwrappedBody, options: []),
                    let jsonString = String(data: jsonData, encoding: .utf8) else
                {
                    throw CredentialsError.bodyNotValidJSON
                }
                
                bodyString = jsonString
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
    }
}
