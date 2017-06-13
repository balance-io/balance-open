//
//  PoloniexAPI.swift
//  BalanceForBlockchain
//
//  Created by Raimon Lapuente on 13/06/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Security

fileprivate let tradingURL = URL(string: "https://poloniex.com/tradingApi")!
fileprivate let APIKEY = "U78QPSJT-9JW9F28T-IMQW7PI8-5VUKB8ZV"

typealias APIKeys = (key: String, secret: String)
typealias SuccessErrorBlock = (_ success: Bool, _ error: Error) -> Void

struct PoloniexAPI {
    
    let body: String
    let hash: String
    let keys: APIKeys
    var bodyData: Data {
        return body.data(using: .utf8)!
    }
    var urlRequest: URLRequest {
        var request = URLRequest(url: tradingURL)
        request.setValue(keys.key, forHTTPHeaderField: "Key")
        request.setValue(hash, forHTTPHeaderField: "Sign")
        request.httpBody = bodyData
        request.httpMethod = "POST"
        return request
    }
    
    init(params: [String: String], keys: APIKeys) {
        self.keys = keys
        
        let nonce = Int64(Date().timeIntervalSince1970 * 1000)
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        queryItems.append(URLQueryItem(name: "nonce", value: "\(nonce)"))
        var components = URLComponents()
        components.queryItems = queryItems
        let body = components.query!
        let hash = body.hmac(algorithm: HMACECase.SHA512, key: keys.secret)
        
        self.body = body
        self.hash = hash
    }
    
}

enum HMACECase {
    case SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: CInt = 0
        switch self {
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    func hmac(algorithm: HMACECase, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
}
