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
    
}


internal extension GDAXAPIClient
{
    internal struct Credentials
    {
        // Internal
        internal let key: String
        internal let secret: String
        internal let passphrase: String
        
        // MARK: Signature
        
        internal func generateSignature(timestamp: Date, requestPath: String, body: [String : Any], method: String) throws -> String
        {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else
            {
                abort()
            }
            
            let message = "\(timestamp.timeIntervalSince1970)\(method)\(requestPath)\(jsonString)"
            print(message)
            
            guard let decodedSecretData = Data(base64Encoded: self.secret), // Decode the secret
                  let messageData = message.data(using: .utf8) else
            {
                abort()
            }
            
            // Create the signature
            let signatureCapacity = Int(CC_SHA256_DIGEST_LENGTH)
            let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: signatureCapacity)
            defer
            {
                signature.deallocate(capacity: signatureCapacity)
            }
        
            decodedSecretData.withUnsafeBytes({ (secretBytes: UnsafePointer<UInt8>) -> Void in
                messageData.withUnsafeBytes({ (messageBytes: UnsafePointer<UInt8>) -> Void in
                    let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
                    CCHmac(algorithm, secretBytes, decodedSecretData.count, messageBytes, messageData.count, signature)
                })
            })
            
            let signatureData = Data(bytes: signature, count: signatureCapacity)
            return signatureData.base64EncodedString()
        }
    }
}
