//
//  AbstractApi.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public enum ApiRequestType {
    case accounts
    case transactions
}

public enum ApiRequestMethod: String {
    case get = "GET"
    case post = "POST"
    
    // These may be needed later
    case put = "PUT"
    case delete = "DELETE"
}

public enum ApiRequestDataFormat {
    // Always used for GET requests, can be used for POST requests when using "application/x-www-form-urlencoded" content type
    case urlEncoded
    
    // Can be used for POST requests
    case json
}

public enum BaseError: Error {
    case internetConnection
    case invalidCredentials(statusCode: Int?)
    case invalidServer(statusCode: Int)
    case other(message: String)
    
    var localizedDescription: String {
        switch self {
        case .internetConnection:
            return "No Internet Connection"
        case .invalidCredentials(_):
            return "Invalid credentials, try again"
        case .invalidServer(_):
            return "We have problems with the server, please try later"
        case .other(let message):
            return "Error: \(message)"
        }
    }
}

public enum ApiRequestEncoding {
    case none
    case hmac512
}

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
    
    // This creates the async network operation based on the overridden options, encapsulates it in an AsyncOperation,
    // and returns that for queuing. The completion handler is called when the operation completes.
    func performRequest(type: ApiRequestType, completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation {
        fatalError("not implemented yet")
    }
    
    // Look for api specific errors (some use http status codes, some use info in the data) and return either
    // a standardized error or nil if no error
    open func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data, error: Error?) -> Error? {
        fatalError("Must override")
    }
    
    // At this point we know there are no errors, so parse the data and return the exchagne data model
    open func processData(requestType: ApiRequestType, data: Data) -> [Any] {
        fatalError("Must override")
    }
    
    // MARK - ExchangeApi Protocol -
    
    public func getAccounts(completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation {
        return performRequest(type: .accounts, completion: completion)
    }
    
    public func getTransactions(completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation {
        return performRequest(type: .transactions, completion: completion)
    }
}
