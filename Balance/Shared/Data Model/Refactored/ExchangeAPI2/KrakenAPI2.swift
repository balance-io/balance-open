//
//  KrakenAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/26/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class KrakenAPI2: AbstractApi {
    override var requestMethod: ApiRequestMethod { return .post }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .hmac(hmacAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA512), digestLength: Int(CC_SHA512_DIGEST_LENGTH)) }
    override var encondingMessageType: ApiEncondingMessageType { return .base64 }
    
    override func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data?, error: Error?) -> Error?  {
        // In this example, look for 400 or 403 errors and return .invalidCredentials, then look for
        // correct data format and either return .other or nil
        fatalError("not implemented")
    }
    
    override func processData(requestType: ApiRequestType, data: Data) -> [Any] {
        // Parse the JSON into [PoloniexAccount] or [PoloniexInstitution] depending on request type
        // and return for handling in the completion block by the app
        fatalError("not implemented")
    }
    
    //MARK: Builder methods for Request
    override func createRequest(for action: APIAction) -> URLRequest? {
        
        switch action.type {
        case .accounts, .transactions:
            return nil
        }
        
    }
    
}
