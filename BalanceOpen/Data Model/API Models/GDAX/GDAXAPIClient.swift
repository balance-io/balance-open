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
}

// MARK: Accounts

internal extension GDAXAPIClient
{
    internal func fetchAccounts(_ completionHandler: @escaping (_ accounts: [Account]?, _ error: APIError?) -> Void)
    {
        guard let unwrappedCredentials = self.credentials else
        {
            // TODO: throw
            return
        }
        
        let requestPath = "/accounts"
        let headers = try! AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: "GET", body: nil)
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
            
        task.resume()
    }
}
