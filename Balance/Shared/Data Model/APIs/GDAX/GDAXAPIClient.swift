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
    
    internal required init(server: Server, session: URLSession = certValidatedSession)
    {
        self.session = session
        self.server = server
    }
    
    static var gdaxInstitution: GdaxInstitution {
        get {
            return GdaxInstitution()
        }
    }
    
    class GdaxInstitution: ApiInstitution {
        let source: Source = .gdax
        let sourceInstitutionId: String = ""
        
        var currencyCode: String = ""
        var usernameLabel: String = ""
        var passwordLabel: String = ""
        var name: String = "GDAX"
        var products: [String] = []
        var type: String = ""
        var url: String? = "https://www.gdax.com/"
        var fields: [Field]
        
        init() {
            let keyField = Field(name: "Key", label: "Key", type: "key", value: nil)
            let secretField = Field(name: "Secret", label: "Secret", type: "secret", value: nil)
            let passphraseField = Field(name: "Passphrase", label: "Passphrase", type: "passphrase", value: nil)
            self.fields = [keyField, secretField, passphraseField]
        }
    }
}

// MARK: Accounts

internal extension GDAXAPIClient
{
    internal func fetchAccounts(_ completionHandler: @escaping (_ accounts: [Account]?, _ error: APIError?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw APICredentialsComponents.Error.noCredentials
        }
        
        let requestPath = "/accounts"
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: "GET", body: nil)
        let url = self.server.url().appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.add(headers: headers.dictionary)
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            do {
            guard let httpResponse = response as? HTTPURLResponse,
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) else
            {
                completionHandler(nil, GDAXAPIClient.APIError.invalidJSON)
                return
            }
            
            if case 200...299 = httpResponse.statusCode {
                guard let accountsJSON = json as? [[String : Any]] else {
                    // return invalid json
                    fatalError()
                }
                
                // Build accounts
                var accounts = [GDAXAPIClient.Account]()
                for accountJSON in accountsJSON {
                    do {
                        let account = try Account(dictionary: accountJSON)
                        accounts.append(account)
                    }
                    catch { }
                }
                
                completionHandler(accounts, nil)
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

// MARK: Withdraw

internal extension GDAXAPIClient {
    internal func make(withdrawal: Withdrawal, completionHandler: @escaping (_ success: Bool, _ error: APIError?) -> Void) throws {
        guard let unwrappedCredentials = self.credentials else {
            throw APICredentialsComponents.Error.noCredentials
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
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            if case 200...299 = httpResponse.statusCode {
                completionHandler(true, nil)
            } else {
                let error = APIError.response(httpResponse: httpResponse, data: data)
                completionHandler(false, error)
            }
        }
        
        task.resume()
    }
}

extension GDAXAPIClient: ExchangeApi {
    func authenticate(secret: String, key: String) {
        assert(false, "implement")
    }
    
    func authenticate(secret: String, key: String, passphrase: String) {
        assert(false, "implement")
    }
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        
        assert(loginStrings.count == 3, "number of auth fields should be 2 for Poloniex")
        var secretField : String?
        var keyField : String?
        var passphrasField: String?
        for field in loginStrings {
            if field.type == "key" {
                keyField = field.value
            } else if field.type == "secret" {
                secretField = field.value
            } else if field.type == "passphrase" {
                passphrasField = field.value
            } else {
                assert(false, "wrong fields are passed into the poloniex auth, we require secret and key fields and values")
            }
        }
        guard let secret = secretField, let key = keyField, let passphrase = passphrasField else {
            assert(false, "wrong fields are passed into the poloniex auth, we require secret and key fields and values")
            closeBlock(false, "wrong fields are passed into the poloniex auth, we require secret and key fields and values", nil)
            return
        }
        
        do {
            let credentials = try GDAXAPIClient.Credentials(key: key, secret: secret, passphrase: passphrase)
            
            self.credentials = credentials
            try self.fetchAccounts { _, error in
                guard let unwrappedError = error else {
                    do {
                        let credentialsIdentifier = "main"
                        try credentials.save(identifier: credentialsIdentifier)
                        let institution = InstitutionRepository.si.institution(source: .gdax, sourceInstitutionId: "", name: "GDAX")
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
                print(unwrappedError)
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
