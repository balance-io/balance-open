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
    open func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data) -> ExchangeError? {
        fatalError("Must override")
    }
    
    // At this point we know there are no errors, so parse the data and return the exchagne data model
    open func processData(requestType: ApiRequestType, data: Data) -> [Any] {
        fatalError("Must override")
    }
    
    // MARK - ExchangeApi Protocol -
    
    public func fetchData(for action: APIAction, completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation {
        return performRequest(type: action.type, completion: completion)
    }
    
}

private extension AbstractApi {
    
    // This creates the async network operation based on the overridden options, encapsulates it in an AsyncOperation,
    // and returns that for queuing. The completion handler is called when the operation completes.
    func performRequest(type: ApiRequestType, completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation {
        fatalError("Must override")
    }
    
}

// MARK: Helper functions
extension AbstractApi {
    
    func generateMessageSigned(for action: APIAction) -> String? {
        guard let message = createMessage(for: action) else {
            return nil
        }
        
        switch requestEncoding {
        case .hmac256:
            return CryptoAlgorithm.sha256.hmac(body: message, key: action.credentials.secretKey)
        case .hmac512:
            return CryptoAlgorithm.sha512.hmac(body: message, key: action.credentials.secretKey)
        default:
            return nil
        }
    }
    
}
