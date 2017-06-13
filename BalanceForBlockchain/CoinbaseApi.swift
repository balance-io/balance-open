//
//  CoinbaseApi.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import AppKit
import Locksmith

typealias SuccessErrorBlock = (_ success: Bool, _ error: Error) -> Void

fileprivate let connectionTimeout = 30.0
fileprivate let baseUrl = "http://localhost:8000/"
fileprivate let clientId = "e47cf82db1ab3497eb06f96bcac0dde027c90c24a977c0b965416e7351b0af9f"

// Save random state for current authentication request
fileprivate var lastState: String? = nil

fileprivate let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)

struct CoinbaseApi {

    static func authenticate() -> Bool {
        let redirectUri = "balancemymoney%3A%2F%2Fcoinbase"
        let responseType = "code"
        let scope = "wallet%3Auser%3Aread"
        let state = String.random(32)
        let url = "https://www.coinbase.com/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&state=\(state)&response_type=\(responseType)&scope=\(scope)"
        
        do {
            _ = try NSWorkspace.shared().open(URL(string: url)!, options: [], configuration: [:])
        } catch {
            // TODO: Better error handling
            print("Error opening Coinbase authentication URL: \(error)")
            return false
        }
        
        // Save random state for verification
        lastState = state
        return true
    }
    
    static func handleAuthenticationCallback(state: String, code: String, completion: @escaping SuccessErrorBlock) {
        guard lastState == state else {
            DispatchQueue.main.async {
                completion(false, "state does not match saved state")
            }
            return
        }
        
        lastState = nil
        let urlString = "\(baseUrl)coinbase/convertCode"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        let parameters = "{\"code\":\"\(code)\"}"
        request.httpBody = parameters.data(using: .utf8)
        
        // TODO: Create enum types for each error
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw "No data"
                }

                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject], let accessToken = JSONResult["accessToken"] as? String, let refreshToken = JSONResult["refreshToken"] as? String, let expiresIn = JSONResult["expiresIn"] as? TimeInterval else {
                    throw "JSON decoding failed"
                }
                
                // Create the institution and finish
                let institution = Institution(sourceId: .coinbase, sourceInstitutionId: "", name: "Coinbase", nameBreak: nil, primaryColor: nil, secondaryColor: nil, logoData: nil, accessToken: accessToken)
                institution?.refreshToken = refreshToken
                institution?.tokenExpireDate = Date().addingTimeInterval(expiresIn - 10.0)
                DispatchQueue.main.async {
                    completion(false, "state does not match saved state")
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        })
        
        task.resume()
    }
}

extension Institution {
    fileprivate var refreshTokenKey: String {
        return "refreshToken institutionId: \(institutionId)"
    }
    
    var refreshToken: String? {
        get {
            var refreshToken: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: refreshTokenKey) {
                refreshToken = dictionary["refreshToken"] as? String
            }
            
            print("get refreshTokenKey: \(refreshTokenKey)  refreshToken: \(String(describing: refreshToken))")
            if refreshToken == nil {
                // We should always be getting an refresh token becasuse we never read it until after it's been written
                log.severe("Tried to read refresh token for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return refreshToken
        }
        set {
            print("set refreshTokenKey: \(refreshTokenKey)  newValue: \(String(describing: newValue))")
            if let refreshToken = newValue {
                do {
                    try Locksmith.updateData(data: ["refreshToken": refreshToken], forUserAccount: refreshTokenKey)
                } catch {
                    log.severe("Couldn't update refreshToken keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if refreshToken != self.refreshToken {
                    log.severe("Saved access token for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: refreshTokenKey)
                } catch {
                    log.severe("Couldn't delete refreshToken keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: refreshTokenKey)
                if dictionary != nil {
                    log.severe("Deleted access token for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
    
    fileprivate static let tokenExpireDateKey = "tokenExpireDateKey"
    fileprivate var tokenExpireDate: Date {
        get {
            return UserDefaults.standard.object(forKey: Institution.tokenExpireDateKey) as? Date ?? Date.distantPast
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Institution.tokenExpireDateKey)
        }
    }
    
    var isTokenExpired: Bool {
        return Date().timeIntervalSince(tokenExpireDate) > 0.0
    }
}
