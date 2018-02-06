//
//  AbstractApi.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

// This class does all of the heavy lifting: i.e. URLSession, preparing requests, etc
open class AbstractApi: ExchangeApi2 {

    open var requestMethod: ApiRequestMethod { return .get }
    open var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    open var requestEncoding: ApiRequestEncoding { return .none }
    open var encondingMessageType: ApiEncondingMessageType { return .none }
    open var requestHandler: RequestHandler? { return nil }
    private var session: URLSession
    
    // certValidatedSession should always be passed here when using in the app except for tests
    public init(session: URLSession) {
        self.session = session
    }
    
    open func createRequest(for action: APIAction) -> URLRequest? {
        fatalError("Must override")
    }
    
    open func createMessage(for action: APIAction) -> String? {
        fatalError("Must override")
    }
    
    // Look for api specific errors (some use http status codes, some use info in the data) and return either
    // a standardized error or nil if no error
    func processErrors(response: URLResponse?, data: Data?, error: Error?) -> Error?  {
        fatalError("Must override")
    }
    
    // At this point we know there are no errors, so parse the data and return the exchagne data model
    open func processData(requestType: ApiRequestType, data: Data) -> Any {
        fatalError("Must override")
    }
    
    public func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        guard let request = createRequest(for: action), let handler = requestHandler else {
            completion(false, nil, nil)
            return nil
        }
        return ExchangeOperation(with: handler, action: action, session: session, request: request, resultBlock: completion)
    }
    
    //mark: Needed for OAUTH
    open func prepareForAutentication() {
        fatalError("Must override")
    }
    
    open func startAutentication(with data: Any, completionBlock: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        fatalError("Must override")
    }
    
}

// MARK: Helper functions
extension AbstractApi {
    func generateMessageSigned(from message: Data, secretKeyEncoded: Data) -> String? {
        guard let dataSigned = createSignatureData(with: message, secretKeyData: secretKeyEncoded) else {
            return nil
        }
        
        switch encondingMessageType {
        case .base64:
            return dataSigned.base64EncodedString()
        case .concatenate(let format):
            return dataSigned.reduce("") { (result, byte) -> String in
                return result + String(format: format, byte)
            }
        default:
            return nil
        }
    }
    
    func generateMessageSigned(for action: APIAction) -> String? {
        guard let message = createMessage(for: action) else {
            return nil
        }
        
        switch requestEncoding {
        case .simpleHmacSha512:
            return CryptoAlgorithm.sha512.hmac(body: message, key: action.credentials.secretKey)
        default:
            return nil
        }
    }
    
    private func createSignatureData(with message: Data, secretKeyData: Data) -> Data? {
        // Create the signature
        guard case let .hmac(algorithm, digestLength) = requestEncoding else {
            return nil
        }
        
        let signatureCapacity = digestLength
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: signatureCapacity)
        defer {
            signature.deallocate(capacity: signatureCapacity)
        }
        
        secretKeyData.withUnsafeBytes({ (secretBytes: UnsafePointer<UInt8>) -> Void in
            message.withUnsafeBytes({ (messageBytes: UnsafePointer<UInt8>) -> Void in
                CCHmac(algorithm, secretBytes, secretKeyData.count, messageBytes, message.count, signature)
            })
        })
        
        return Data(bytes: signature, count: signatureCapacity)
    }
}
