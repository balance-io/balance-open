//
//  GDAXAPIClient.swift
//  BalanceOpen
//
//  Created by Red Davis on 25/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class GDAXAPIClient
{
    // Private
    private let server: Server
    
    // MARK: Initialization
    
    internal required init(server: Server)
    {
        self.server = server
    }
}

// MARK: Server

internal extension GDAXAPIClient
{
    internal enum Server
    {
        case sandbox, production
        
        // MARK: URL
        
        internal func url() -> URL
        {
            switch self
            {
            case .production:
                return URL(string: "https://api.gdax.com")!
            case .sandbox:
                return URL(string: "https://api-public.sandbox.gdax.com")!
            }
        }
    }
}


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
                throw Error.invalidSecret(message: "Secret is not base64 encoded")
            }
            
            self.key = key
            self.secret = secret
            self.passphrase = passphrase
            self.decodedSecretData = decodedSecretData
        }
        
        // MARK: Signature
        
        internal func generateSignature(timestamp: Date, requestPath: String, body: [String : Any], method: String) throws -> String
        {
            // Turn body into JSON string
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else
            {
                throw Error.bodyNotValidJSON
            }
            
            // Message
            let message = "\(timestamp.timeIntervalSince1970)\(method)\(requestPath)\(jsonString)"
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

internal extension GDAXAPIClient.Credentials
{
    internal enum Error: Swift.Error
    {
        case invalidSecret(message: String)
        case bodyNotValidJSON
    }
}
