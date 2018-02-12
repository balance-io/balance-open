//
//  AbstractApi.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

// This class does all of the heavy lifting: i.e. URLSession, preparing requests, etc
open class AbstractApi: ExchangeApi2, ResponseHandler {

    open var requestMethod: ApiRequestMethod { return .get }
    open var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    open var requestEncoding: ApiRequestEncoding { return .none }
    open var encondingMessageType: ApiEncondingMessageType { return .none }
    open var shouldHandleNoActionResponse: Bool { return false }
    private var session: URLSession
    
    // certValidatedSession should always be passed here when using in the app except for tests
    public init(session: URLSession) {
        self.session = session
    }
    
    public func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        guard let request = createRequest(for: action) else {
            completion(false, nil, nil)
            return nil
        }
        return ExchangeOperation(with: self, action: action, session: session, request: request, resultBlock: completion)
    }
    
    open func processBaseErrors(data: Data?, error: Error?, response: URLResponse?) -> Error? {
        if let error = error as NSError?, error.code == -1009, error.code == -1001 {
            return ExchangeBaseError.internetConnection
        }
        
        guard let response = response as? HTTPURLResponse else {
            return ExchangeBaseError.other(message: "response malformed")
        }
        
        switch response.statusCode {
        case 400...499:
            return ExchangeBaseError.invalidCredentials(statusCode: response.statusCode)
        case 500...599:
            return ExchangeBaseError.invalidServer(statusCode: response.statusCode)
        default:
            return nil
        }
    }
    
    open func createRequest(for action: APIAction) -> URLRequest? {
        fatalError("Must override")
    }
    
    open func createMessage(for action: APIAction) -> String? {
        fatalError("Must override")
    }
    
    open func processApiErrors(from data: Data) -> Error? {
        fatalError("Must override")
    }
    
    open func buildAccounts(from data: Data) -> Any {
        fatalError("Must override")
    }

    open func buildTransactions(from data: Data) -> Any {
        fatalError("Must override")
    }
    
    open func buildDataFromNoAction(_ data: Data?) -> Any {
        fatalError("Must override")
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
    
    public func handleResponseData(for action: APIAction?, data: Data?, error: Error?, urlResponse ulrResponse: URLResponse?) -> Any {
        guard let action = action else {
            let noActionData = shouldHandleNoActionResponse ? buildDataFromNoAction(data) :
                ExchangeBaseError.other(message: "No action provided")
            
            return noActionData
        }
        
        if let error = processErrors(response: ulrResponse, data: data, error: error) {
            return error
        }
        
        return processData(requestType: action.type, data: data)
    }
    
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
        case .simpleHmacSha256:
            return CryptoAlgorithm.sha256.hmac(body: message, key: action.credentials.secretKey)
        default:
            return nil
        }
    }
    
    func encodeCredentialsWithBaseAuthentication(with action: APIAction) -> BasicAuthenticationCredentialsResult? {
        guard case .baseAuthentication = requestEncoding else {
            print("Invalid request encoding type")
            return nil
        }
        
        guard let credentialsData = "\(action.credentials.apiKey):\(action.credentials.secretKey)".data(using: .utf8) else {
            print("Credentials can't be tranformed to data")
            return nil
        }
        
        return ("Authorization" ,"Basic \(credentialsData.base64EncodedString())")
    }
    
}

private extension AbstractApi {
    
    // Look for api specific errors (some use http status codes, some use info in the data) and return either
    // a standardized error or nil if no error
    func processErrors(response: URLResponse?, data: Data?, error: Error?) -> Error?  {
        if let baseError = processBaseErrors(data: data, error: error, response: response) {
            return baseError
        }
        
        guard let data = data else {
            return ExchangeBaseError.other(message: "no data to manage")
        }
        
        return processApiErrors(from: data)
    }
    
    // At this point we know there are no errors, so parse the data and return the exchagne data model
    func processData(requestType: ApiRequestType, data: Data?) -> Any {
        guard let data = data else { return [] }
        return requestType == .accounts ? buildAccounts(from: data) : buildTransactions(from: data)
    }
    
    func createSignatureData(with message: Data, secretKeyData: Data) -> Data? {
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
