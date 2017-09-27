//
//  BitfinexAPIClient.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class BitfinexAPIClient
{
    // Internal
    internal var credentials: Credentials?

    // Private
    private let session: URLSession
    private let baseURL = URL(string: "https://api.bitfinex.com")!
    
    // MARK: Initialization
    
    internal required init(session: URLSession)
    {
        self.session = session
    }
    
    internal convenience init()
    {
        self.init(session: certValidatedSession)
    }
    
    static let institution = BitfinexInstitution()
    
    class BitfinexInstitution: ApiInstitution {
        let source: Source = .bitfinex
        let sourceInstitutionId: String = ""
        
        var currencyCode: String = ""
        var usernameLabel: String = ""
        var passwordLabel: String = ""
        var name: String = "Bitfinex"
        var products: [String] = []
        var type: String = ""
        var url: String? = "https://www.bitfinex.com/"
        var fields: [Field]
        
        // MARK: Initialization
        
        init() {
            let keyField = Field(name: "Key", label: "Key", type: "key", value: nil)
            let secretField = Field(name: "Secret", label: "Secret", type: "secret", value: nil)
            self.fields = [keyField, secretField]
        }
    }
}

// MARK: Wallets

internal extension BitfinexAPIClient
{
    internal func fetchWallets(_ completionHandler: @escaping (_ wallets: [Wallet]?, _ error: APIError?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw APICredentialsComponents.Error.noCredentials
        }
        
        let requestPath = "v2/auth/r/wallets"
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, body: nil)
        let url = self.baseURL.appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.add(headers: headers.dictionary)
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            do
            {
                guard let httpResponse = response as? HTTPURLResponse,
                      let unwrappedData = data,
                      let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) else
                {
                    completionHandler(nil, APIError.invalidJSON)
                    return
                }

                if case 200...299 = httpResponse.statusCode {
                    guard let walletsJSON = json as? [[Any]] else
                    {
                        completionHandler(nil, APIError.invalidJSON)
                        return
                    }
                    
                    // Build wallets
                    var wallets = [BitfinexAPIClient.Wallet]()
                    for walletJSON in walletsJSON
                    {
                        do
                        {
                            let wallet = try Wallet(data: walletJSON)
                            wallets.append(wallet)
                        }
                        catch { }
                    }
                    
                    completionHandler(wallets, nil)
                } else if case 400...402 = httpResponse.statusCode {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                    throw APICredentialsComponents.Error.invalidSecret(message: "One or more of your credentials is invalid")
                } else if case 403...499 = httpResponse.statusCode {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                    throw APICredentialsComponents.Error.missingPermissions
                } else {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                }
            } catch {}
        }
        
        task.resume()
    }
}

// MARK: Transactions

internal extension BitfinexAPIClient
{
    internal func fetchTransactions(_ completionHandler: @escaping (_ transactions: [Transaction]?, _ error: APIError?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw APICredentialsComponents.Error.noCredentials
        }
        
        let requestPath = "v2/auth/r/movements/hist"
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, body: nil)
        let url = self.baseURL.appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.add(headers: headers.dictionary)
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            do
            {
                guard let httpResponse = response as? HTTPURLResponse,
                      let unwrappedData = data,
                      let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) else
                {
                    completionHandler(nil, APIError.invalidJSON)
                    return
                }

                if case 200...299 = httpResponse.statusCode {
                    guard let transactionsJSON = json as? [[Any]] else
                    {
                        completionHandler(nil, APIError.invalidJSON)
                        return
                    }
                    
                    print(json)
                    
                    // Build transactions
                    var transactions = [BitfinexAPIClient.Transaction]()
                    for transactionJSON in transactionsJSON
                    {
                        do
                        {
                            let transaction = try Transaction(data: transactionJSON)
                            transactions.append(transaction)
                        }
                        catch { }
                    }
                    
                    completionHandler(transactions, nil)
                } else if case 400...402 = httpResponse.statusCode {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                    throw APICredentialsComponents.Error.invalidSecret(message: "One or more of your credentials is invalid")
                } else if case 403...499 = httpResponse.statusCode {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                    throw APICredentialsComponents.Error.missingPermissions
                } else {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                }
            } catch {}
        }
        
        task.resume()
    }
}

// MARK: ExchangeApi

extension BitfinexAPIClient: ExchangeApi {
    func authenticate(secret: String, key: String) {
        assert(false, "implement")
    }
    
    func authenticate(secret: String, key: String, passphrase: String) {
        assert(false, "implement")
    }
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        assert(loginStrings.count == 2, "number of auth fields should be 2 for Bitfinex")
        
        var secretField: String?
        var keyField: String?
        
        for field in loginStrings {
            switch field.type {
            case "key":
                keyField = field.value
            case "secret":
                secretField = field.value
            default:
                assert(false, "wrong fields are passed into the Bitfinex auth, we require secret and key fields and values")
            }
        }
        
        guard let secret = secretField,
              let key = keyField else {
            assert(false, "wrong fields are passed into the Bitfinex auth, we require secret and key fields and values")
            closeBlock(false, "wrong fields are passed into the Bitfinex auth, we require secret and key fields and values", nil)
                
            return
        }
        
        do {
            let credentials = try BitfinexAPIClient.Credentials(key: key, secret: secret)
            
            self.credentials = credentials
            try self.fetchWallets { _, error in
                guard let unwrappedError = error else {
                    do {
                        let credentialsIdentifier = "main"
                        try credentials.save(identifier: credentialsIdentifier)
                        let institution = InstitutionRepository.si.institution(source: .bitfinex, sourceInstitutionId: "", name: "Bitfinex")
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
