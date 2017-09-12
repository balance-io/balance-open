//
//  APICredentials.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith


internal protocol APICredentials
{
    var components: APICredentialsComponents { get }
    var hmacAlgorithm: CCHmacAlgorithm { get }
    
    init(identifier: String) throws
    init(component: APICredentialsComponents)
    
    func createSignature(with message: String) -> String
    func namespacedKeychainIdentifier(_ identifier: String) -> String
    func save(identifier: String) throws
}


// MARK: Default implementations

internal extension APICredentials
{
    // MARK: Saving
    
    internal func save(identifier: String) throws
    {
        let namespacedIdentifier = self.namespacedKeychainIdentifier(identifier)
        
        do
        {
            try Locksmith.saveData(data: self.components.dictionary, forUserAccount: namespacedIdentifier)
        }
        catch LocksmithError.duplicate
        {
            try Locksmith.updateData(data: self.components.dictionary, forUserAccount: namespacedIdentifier)
        }
        catch let error
        {
            throw error
        }
    }
    
    // MARK: Signature
    
    internal func createSignature(with message: String) -> String
    {
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
        
        self.components.decodedSecretData.withUnsafeBytes({ (secretBytes: UnsafePointer<UInt8>) -> Void in
            messageData.withUnsafeBytes({ (messageBytes: UnsafePointer<UInt8>) -> Void in
                CCHmac(self.hmacAlgorithm, secretBytes, self.components.decodedSecretData.count, messageBytes, messageData.count, signature)
            })
        })
        
        let signatureData = Data(bytes: signature, count: signatureCapacity)
        return signatureData.base64EncodedString()
    }
}
