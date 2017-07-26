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
    // Internal
    internal var credentials: Credentials?
    
    // Private
    private let server: Server
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // MARK: Initialization
    
    internal required init(server: Server)
    {
        self.server = server
    }
    
    // MARK: Accounts
    
    internal func fetchAccounts(_ completionHandler: @escaping () -> Void)
    {
        guard let unwrappedCredentials = self.credentials else
        {
            // TODO: throw
            return
        }
        
        let requestPath = "/accounts"
        let headers = try! HTTPHeader(credentials: unwrappedCredentials, requestPath: requestPath, method: "GET", body: [:])
        let url = self.server.url().appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        
        for (key, value) in headers.dictionary
        {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            let json = try! JSONSerialization.jsonObject(with: data!, options: [])
            print(json)
            print(data)
            print(response)
            print(error)
        }.resume()
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

// MARK: HTTP Header

internal extension GDAXAPIClient
{
    internal struct HTTPHeader
    {
        // Internal
        internal let dictionary: [String : String]

        // MARK: Initialization
        
        internal init(credentials: Credentials, requestPath: String, method: String, body: [String : Any]) throws
        {
            let nowDate = Date()
            let signature = try credentials.generateSignature(timestamp: nowDate, requestPath: requestPath, body: body, method: method)
            
            self.dictionary = [
                "CB-ACCESS-KEY" : credentials.key,
                "CB-ACCESS-SIGN" : signature,
                "CB-ACCESS-TIMESTAMP" : "\(nowDate.timeIntervalSince1970)",
                "CB-ACCESS-PASSPHRASE" : credentials.passphrase
            ]
        }
    }
}

// MARK: Credentials

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
