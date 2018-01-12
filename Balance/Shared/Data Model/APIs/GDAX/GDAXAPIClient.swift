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
            let keyField = Field(name: "API Key", type: .key, value: nil)
            let secretField = Field(name: "API Secret", type: .secret, value: nil)
            let passphraseField = Field(name: "Passphrase", type: .passphrase, value: nil)
            self.fields = [keyField, secretField, passphraseField]
        }
    }
}

// MARK: Accounts

extension GDAXAPIClient
{
    func fetchAccounts(_ completionHandler: @escaping (_ accounts: [Account]?, _ error: APIError?) -> Void) throws
    {
        guard let unwrappedCredentials = self.credentials else
        {
            throw APICredentialsComponents.Error.noCredentials
        }
        
        let requestPath = "/accounts"
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: HTTPMethod.GET, body: nil)
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
                async {
                    completionHandler(accounts, nil)
                }
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
    
    func fetchTranactions(accountId: String, currencyCode: String,_ completionHandler: @escaping (_ accounts: [Transaction]?, _ error: APIError?) -> Void) throws {
        guard let unwrappedCredentials = self.credentials else {
            throw APICredentialsComponents.Error.noCredentials
        }
        let requestPath = "/accounts/\(accountId)/ledger"
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: HTTPMethod.GET, body: nil)
        let url = self.server.url().appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.add(headers: headers.dictionary)
        
        // Perform request
        let task = self.session.dataTask(with: request) { (data, response, error) in
            do {
                guard let httpResponse = response as? HTTPURLResponse,
                    let json = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                        async {
                            completionHandler(nil, GDAXAPIClient.APIError.invalidJSON)
                        }
                    return
                }
                
                if case 200...299 = httpResponse.statusCode {
                    guard let transactionsJSON = json as? [[String : Any]] else {
                        // return invalid json
                        throw GDAXAPIClient.APIError.invalidJSON
                    }
                    
                    // Build accounts
                    var transactions = [GDAXAPIClient.Transaction]()
                    for transaction in transactionsJSON {
                        do {
                            let transactoinObject = try Transaction.init(dictionary: transaction, currencyCode: currencyCode)
                            transactions.append(transactoinObject)
                        }
                        catch {
                            completionHandler(nil, error as? GDAXAPIClient.APIError)
                        }
                    }
                    completionHandler(transactions, nil)
                    // TO DO
                    // change the institution boolean passwordInvalid to a bool and convert to enum and then modify here if an error happens with the appropiate enum
                    // also port all api code errors to a single common error enum
                } else if case 400...402 = httpResponse.statusCode {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
//                    throw APICredentialsComponents.Error.invalidSecret(message: "One or more of your credentials is invalid")
                } else if case 403...499 = httpResponse.statusCode {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
//                    throw APICredentialsComponents.Error.missingPermissions
                } else {
                    let error = APIError.response(httpResponse: httpResponse, data: data)
                    completionHandler(nil, error)
                }
            } catch {
                completionHandler(nil, error as? GDAXAPIClient.APIError)
            }
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
        
        let headers = try AuthHeaders(credentials: unwrappedCredentials, requestPath: requestPath, method: HTTPMethod.POST, body: body)
        let url = self.server.url().appendingPathComponent(requestPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST
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
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution? = nil, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        
        assert(loginStrings.count == 3, "number of auth fields should be 3 for GDAX")
        var secretField : String?
        var keyField : String?
        var passphrasField: String?
        for field in loginStrings {
            if field.type == .key {
                keyField = field.value?.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if field.type == .secret {
                secretField = field.value?.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if field.type == .passphrase {
                passphrasField = field.value?.trimmingCharacters(in: .whitespacesAndNewlines)
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
            try self.fetchAccounts { accounts, error in
                guard let unwrappedError = error else {
                    do {
                        let credentialsIdentifier = "main"
                        try credentials.save(identifier: credentialsIdentifier)
                        
                        if let existingInstitution = existingInstitution {
                            existingInstitution.accessToken = credentialsIdentifier
                            
                            async {
                                closeBlock(true, nil, existingInstitution)
                            }
                        } else {
                            let newInstitution = InstitutionRepository.si.institution(source: .gdax, sourceInstitutionId: "", name: "GDAX")
                            newInstitution?.accessToken = credentialsIdentifier
                            
                            guard let unwrappedAccounts = accounts, let institution = newInstitution else {
                                async {
                                    closeBlock(false, error, nil)
                                }
                                return
                            }
                            for account in unwrappedAccounts {
                                let currency = Currency.rawValue(account.currencyCode)
                                let currentBalance = account.balance.integerValueWith(decimals: currency.decimals)
                                let availableBalance = account.availableBalance.integerValueWith(decimals: currency.decimals)
                                
                                // Initialize an Account object to insert the record
                                AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: account.identifier, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: account.currencyCode, currency: account.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                            }
                            
                            async {
                                closeBlock(true, nil, institution)
                            }
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
