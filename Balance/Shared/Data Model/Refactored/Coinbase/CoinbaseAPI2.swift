//
//  CoinbaseAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum CoinbaseAuthenticationKey: String {
    case state
    case code
}

fileprivate struct CoinbaseAutenticationConstants {
    
    //mark: Coinbase app configurations
    static let cbVersion = "2017-05-19"
    static let connectionTimeout = 30.0
    static let subServerUrl = debugging.useLocalSubscriptionServer ? "http://localhost:8080/" : "https://api.balancemy.money/"
    static let clientId = "a6e15fbb0c3362b74360895f261fb079672c10eef79dcb72308c974408c5ce43"
    
    //mark: Authentication
    static let redirectUri = "balancemymoney%3A%2F%2Fcoinbase"
    static let responseType = "code"
    static let scope = "wallet%3Auser%3Aread,wallet%3Aaccounts%3Aread,wallet%3Atransactions%3Aread"
    
    static var state: String {
        return String.random(32)
    }
    
    static func getAuthenticationURL(with state: String) -> URL? {
        let autenticationURLText = "https://www.coinbase.com/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&state=\(state)&response_type=\(responseType)&scope=\(scope)&account=all"
        
        return URL(string: autenticationURLText)
    }
    
    static var autenticationCallbackURL: URL? {
        let callbackURL = "\(subServerUrl)coinbase/requestToken"
        
        return URL(string: callbackURL)
    }
    
}


class CoinbaseAPI2: AbstractApi {
    
    private var lastState: String? = nil
    
    override func prepareForAutentication() {
        let state = CoinbaseAutenticationConstants.state

        guard let coinbaseAutenticationURL = CoinbaseAutenticationConstants.getAuthenticationURL(with: state) else {
            log.debug("Error - Coinbase autentication url can't be created")
            return
        }
        
        do {
            #if os(OSX)
                _ = try NSWorkspace.shared.open(coinbaseAutenticationURL, options: [], configuration: [:])
            #else
                UIApplication.shared.open(coinbaseAutenticationURL)
            #endif
        } catch {
            // TODO: Better error handling
            log.error("Error opening Coinbase authentication URL: \(error)")
        }
        
        lastState = state
    }
    
    override func startAutentication(with data: Any, completionBlock: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        guard let autenticationRequest = createAutenticationRequest(with: data) else {
            return nil
        }
        
        return CoibaseAutenticationOperation(autenticationRequest: autenticationRequest,
                                             requestHandler: self,
                                             autenticationResultBlock: completionBlock)
    }
    
}

extension CoinbaseAPI2: RequestHandler {
    
    func request(for action: APIAction) -> URLRequest? {
        return nil
    }
    
    func handleResponseData(_ data: Data?, error: Error?, ulrResponse: URLResponse?) -> Any {
        return "example"
    }
    
}

private extension CoinbaseAPI2 {
    
    func createAutenticationRequest(with data: Any) -> URLRequest? {
        guard let dict = data as? [String: Any],
            let state = dict[CoinbaseAuthenticationKey.state.rawValue] as? String,
            let code = dict[CoinbaseAuthenticationKey.state.rawValue] as? String else {
                log.debug("can't retrive data for begin autentication")
                return nil
        }
        
        guard state == lastState else {
            log.debug("State retrived from autentication callback is different")
            return nil
        }
        
        guard let callbackURL = CoinbaseAutenticationConstants.autenticationCallbackURL else {
            log.debug("Invalid callback url")
            return nil
        }
        
        lastState = nil
        
        var request = URLRequest(url: callbackURL)
        request.timeoutInterval = CoinbaseAutenticationConstants.connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = HTTPMethod.POST
        let parameters = "{\"code\":\"\(code)\"}"
        request.httpBody = parameters.data(using: .utf8)
        
        return request
    }
    
}

private class CoibaseAutenticationOperation: Operation {
    
    private let autenticationResultBlock: ExchangeOperationCompletionHandler
    private let requestHandler: RequestHandler
    private var autenticationRequest: URLRequest
    
    init(autenticationRequest: URLRequest, requestHandler: RequestHandler, autenticationResultBlock: @escaping ExchangeOperationCompletionHandler) {
        self.autenticationRequest = autenticationRequest
        self.requestHandler = requestHandler
        self.autenticationResultBlock = autenticationResultBlock
    }
    
    override func start() {
        main()
    }
    
    override func main() {
        let strongHandler = requestHandler
        let task = certValidatedSession.dataTask(with: autenticationRequest) { (data, response, error) in
            let mockData = strongHandler.handleResponseData(data, error: error, ulrResponse: response)
            self.completionBlock?()
            self.autenticationResultBlock(true, nil, mockData)
        }
        
        task.resume()
    }
    
}
