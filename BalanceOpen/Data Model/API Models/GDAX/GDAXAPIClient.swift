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
    private let session: URLSession
    
    // MARK: Initialization
    
    internal required init(server: Server, session: URLSession = URLSession(configuration: .default))
    {
        self.session = session
        self.server = server
    }
}

// MARK: Accounts

internal extension GDAXAPIClient
{
    internal func fetchAccounts(_ completionHandler: @escaping (_ accounts: [Account]?, _ error: APIError?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw GDAXAPIClient.CredentialsError.noCredentials
        }
        
        let requestPath = "/accounts"
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: "GET", body: nil)
        let url = self.server.url().appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.add(headers: headers.dictionary)
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) else
            {
                return
            }
            
            if case 200...299 = httpResponse.statusCode
            {
                guard let accountsJSON = json as? [[String : Any]] else
                {
                    // return invalid json
                    fatalError()
                }
                
                // Build accounts
                var accounts = [GDAXAPIClient.Account]()
                for accountJSON in accountsJSON
                {
                    do
                    {
                        let account = try Account(dictionary: accountJSON)
                        accounts.append(account)
                    }
                    catch { }
                }
                
                completionHandler(accounts, nil)
            }
            else
            {
                let error = APIError.response(httpResponse: httpResponse, data: data)
                completionHandler(nil, error)
            }
        }
        
        task.resume()
    }
}

// MARK: Withdraw

internal extension GDAXAPIClient
{
    internal func make(withdrawal: Withdrawal, completionHandler: @escaping (_ success: Bool, _ error: APIError?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw GDAXAPIClient.CredentialsError.noCredentials
        }
        
        let requestPath = "/withdrawals/crypto"
        let body = try withdrawal.jsonData()
        
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: "POST", body: body)
        let url = self.server.url().appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        
        request.add(headers: headers.dictionary)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else
            {
                return
            }
            
            if case 200...299 = httpResponse.statusCode
            {
                completionHandler(true, nil)
            }
            else
            {
                let error = APIError.response(httpResponse: httpResponse, data: data)
                completionHandler(false, error)
            }
        }
        
        task.resume()
    }
}
