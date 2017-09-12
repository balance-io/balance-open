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
    var hmacAlgorithmDigestLength: Int { get }
    
    init(identifier: String) throws
    init(component: APICredentialsComponents) throws
    
    func createSignatureData(with message: String, secretKeyData: Data) -> Data
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
    
    internal func createSignatureData(with message: String, secretKeyData: Data) -> Data
    {
        guard let messageData = message.data(using: .utf8) else
        {
            fatalError()
        }
        
        // Create the signature
        
        let signatureCapacity = self.hmacAlgorithmDigestLength
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: signatureCapacity)
        defer
        {
            signature.deallocate(capacity: signatureCapacity)
        }
        
        secretKeyData.withUnsafeBytes({ (secretBytes: UnsafePointer<UInt8>) -> Void in
            messageData.withUnsafeBytes({ (messageBytes: UnsafePointer<UInt8>) -> Void in
                CCHmac(self.hmacAlgorithm, secretBytes, secretKeyData.count, messageBytes, messageData.count, signature)
            })
        })
        
        return Data(bytes: signature, count: signatureCapacity)
    }
}
