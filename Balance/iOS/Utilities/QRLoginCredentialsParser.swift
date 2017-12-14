//
//  QRLoginCredentialsParser.swift
//  BalanceiOS
//
//  Created by Red Davis on 13/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class QRLoginCredentialsParser {
    // Private
    
    // MARK: Initialization
    
    internal required init() {
        
    }
    
    // MARK: Parse
    
    internal func parse(value: String, for source: Source) throws -> [Field]
    {
        switch source
        {
        case .kraken:
            return try self.extractKrakenCredentials(from: value)
        case .bitfinex:
            return try self.extractBitfinexCredentials(from: value)
        default:
            throw ParseError.unsupportedSource
        }
    }
    
    // MARK: -
    
    private func extractKrakenCredentials(from value: String) throws -> [Field] {
        guard let urlComponents = URLComponents(string: value) else {
            throw ParseError.invalidValue
        }
        
        let keyItem = urlComponents.queryItems?.first(where: { (item) -> Bool in
            return item.name == "key"
        })
        
        let secretItem = urlComponents.queryItems?.first(where: { (item) -> Bool in
            return item.name == "secret"
        })
        
        guard let key = keyItem?.value,
              let secret = secretItem?.value else {
            throw ParseError.missingData
        }
        
        // Build fields
        let keyField = Field(name: "Key", type: "key", value: key)
        let secretField = Field(name: "Secret", type: "secret", value: secret)
        
        return [keyField, secretField]
    }
    
    private func extractBitfinexCredentials(from value: String) throws -> [Field] {
        let components = value.split(separator: "-")
        
        var bitfinexKey: String?
        var bitfinexSecret: String?
        
        for component in components {
            let keyValues = component.split(separator: ":")
            guard let key = keyValues.first,
                  let value = keyValues.last,
                      keyValues.count == 2 else {
                continue
            }

            if key == "key" {
                bitfinexKey = String(value)
            } else if key == "secret" {
                bitfinexSecret = String(value)
            }
        }
        
        guard let unwrappedBitfinexKey = bitfinexKey,
              let unwrappedBitfinexSecret = bitfinexSecret else {
            throw ParseError.missingData
        }
        
        // Build fields
        let keyField = Field(name: "Key", type: "key", value: unwrappedBitfinexKey)
        let secretField = Field(name: "Secret", type: "secret", value: unwrappedBitfinexSecret)
        
        return [keyField, secretField]
    }
}


internal extension QRLoginCredentialsParser {
    internal enum ParseError: Error {
        case unsupportedSource
        case invalidValue
        case missingData
    }
}
