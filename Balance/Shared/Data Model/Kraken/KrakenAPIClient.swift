//
//  KrakenAPIClient.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class KrakenAPIClient
{
    // Internal
    internal var credentials: Credentials?
    
    // Private
    private let session: URLSession
    private let baseURL = URL(string: "https://api.kraken.com")!
    
    // MARK: Initialization
    
    internal required init(session: URLSession)
    {
        self.session = session
    }
    
    internal convenience init()
    {
        self.init(session: certValidatedSession)
    }
}

// MARK: Wallets

internal extension KrakenAPIClient
{
    internal func fetchAccounts(_ completionHandler: @escaping (_ accounts: [Account]?, _ error: Error?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw APICredentialsComponents.Error.noCredentials
        }
        
        let requestPath = "/0/private/Balance"
        
        let nonce = String(Int(Date().timeIntervalSinceReferenceDate.rounded() * 1000))
        let body = [
            "nonce" : nonce
        ].httpFormEncode()
        
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, nonce: nonce, body: body)
        let url = self.baseURL.appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.add(headers: headers.dictionary)
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  let unwrappedData = data,
                  let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) else
            {
                completionHandler(nil, APIError.invalidJSON)
                return
            }
            
            if case 200...299 = httpResponse.statusCode {
                guard let responseJSON = json as? [String : Any],
                      let resultJSON = responseJSON["result"] as? [String : String] else
                {
                    completionHandler(nil, APIError.invalidJSON)
                    return
                }
                
                // Build accounts
                var accounts = [KrakenAPIClient.Account]()
                for (currency, balance) in resultJSON
                {
                    do
                    {
                        let account = try Account(currency: currency, balance: balance)
                        accounts.append(account)
                    }
                    catch { }
                }
                
                completionHandler(accounts, nil)
            } else if case 400...402 = httpResponse.statusCode {
                let error = APICredentialsComponents.Error.invalidSecret(message: "One or more of your credentials is invalid")
                completionHandler(nil, error)
            } else if case 403...499 = httpResponse.statusCode {
                let error = APICredentialsComponents.Error.missingPermissions
                completionHandler(nil, error)
            } else {
                let error = APIError.response(httpResponse: httpResponse, data: data)
                completionHandler(nil, error)
            }
        }
        
        task.resume()
    }
}

// MARK: ExchangeApi

extension KrakenAPIClient: ExchangeApi {
    func authenticate(secret: String, key: String) {
        assert(false, "implement")
    }
    
    func authenticate(secret: String, key: String, passphrase: String) {
        assert(false, "implement")
    }
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        assert(loginStrings.count == 2, "number of auth fields should be 2 for Kraken")

        var secretField: String?
        var keyField: String?

        for field in loginStrings {
            switch field.type {
            case "key":
                keyField = field.value
            case "secret":
                secretField = field.value
            default:
                assert(false, "wrong fields are passed into the Kraken auth, we require secret and key fields and values")
            }
        }

        guard let secret = secretField,
            let key = keyField else {
                assert(false, "wrong fields are passed into the Kraken auth, we require secret and key fields and values")
                closeBlock(false, "wrong fields are passed into the Kraken auth, we require secret and key fields and values", nil)

                return
        }

        do {
            let credentials = try KrakenAPIClient.Credentials(key: key, secret: secret)

            self.credentials = credentials
            try self.fetchAccounts { accounts, error in
                guard let unwrappedError = error else {
                    do {
                        let credentialsIdentifier = "main"
                        try credentials.save(identifier: credentialsIdentifier)
                        let institution = InstitutionRepository.si.institution(source: .kraken, sourceInstitutionId: "", name: "Kraken")
                        institution?.accessToken = credentialsIdentifier

                        async {
                            closeBlock(true, nil, institution)
                        }
                    }
                    catch {
                        async {
                            closeBlock(false, error, nil)
                        }
                    }

                    return
                }

                // TODO: Display error
                async {
                    closeBlock(false, unwrappedError, nil)
                }
            }
        }
        catch APICredentialsComponents.Error.invalidSecret {
            // TODO: show alert
            async {
                closeBlock(false, APICredentialsComponents.Error.invalidSecret(message: ""), nil)
            }
        }
        catch {
            // TODO: show alert
            async {
                closeBlock(false, error, nil)
            }
        }
    }
}


// MARK: Institute

internal extension KrakenAPIClient
{
    static let institution = KrakenInstitution()
    
    class KrakenInstitution: ApiInstitution {
        let source: Source = .kraken
        let sourceInstitutionId: String = ""
        
        var currencyCode: String = ""
        var usernameLabel: String = ""
        var passwordLabel: String = ""
        var name: String = "Kraken"
        var products: [String] = []
        var type: String = ""
        var url: String? = "https://www.kraken.com/"
        var fields: [Field]
        
        // MARK: Initialization
        
        init() {
            let keyField = Field(name: "Key", label: "Key", type: "key", value: nil)
            let secretField = Field(name: "Secret", label: "Secret", type: "secret", value: nil)
            self.fields = [keyField, secretField]
        }
    }
}


internal extension Dictionary where Key: StringProtocol, Value: StringProtocol
{
    internal func httpFormEncode() -> String
    {
        var queryItems = [URLQueryItem]()
        for (key, value) in self
        {
            let queryItem = URLQueryItem(name: String(key), value: String(value))
            queryItems.append(queryItem)
        }
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems
        
        return urlComponents.url?.query ?? ""
    }
}
