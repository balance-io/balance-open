//
//  EthplorerApi.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class EthplorerApi: ExchangeApi {
    
    fileprivate enum Commands: String {
        case getTokenInfo
        case getAddressInfo
        case getTxInfo
        case getTokenHistory
        case getAddressHistory
        case getAddressTransactions
        case getTopTokens
        case getTokenHistoryGrouped
        case getTokenPriceHistoryGrouped
    }
    
    // MARK: - Constants -
    
    fileprivate let ethploreToken = "freekey"
    
    fileprivate let EthplorerUrl = URL(string: "https://api.ethplorer.io/")!
    
    // MARK: - Properties -
    
    fileprivate var name: String
    fileprivate var address: String
    
    // MARK: - Lifecycle -
    
    init() {
        self.name = ""
        self.address = ""
    }
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }

    // MARK: - Public -
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution? = nil, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        assert(loginStrings.count == 2, "number of auth fields should be 2 for Ethplorer")
        var nameField : String?
        var addressField : String?
        for field in loginStrings {
            if field.type == .name {
                nameField = field.value
            } else if field.type == .address {
                addressField = field.value
            } else {
                assert(false, "wrong fields are passed into the Ethplore auth, we require secret and key fields and values")
            }
        }
        guard let name = nameField, let address = addressField else {
            assert(false, "wrong fields are passed into the ethplore auth, we require secret and key fields and values")
            closeBlock(false, "wrong fields are passed into the ethlpore auth, we require secret and key fields and values", nil)
            return
        }
        do {
            try authenticate(name: name, address: address, existingInstitution: existingInstitution, closeBlock: closeBlock)
        } catch {
            log.error("Failed to Ethplore wallet data: \(error)")
        }
    }
    
    func fetchAddressInfo(institution: Institution, completion: @escaping SuccessErrorBlock) {
        guard let address = institution.address else {
            assert(false, "Address shouldn't be nil")
            return
        }
        let addressURL = EthplorerUrl.appendingPathComponent("\(Commands.getAddressInfo.rawValue)/\(address)")
        var urlComponent = URLComponents(url: addressURL, resolvingAgainstBaseURL: false)
        var params = [URLQueryItem]()
        params.append(URLQueryItem(name: "apiKey", value: ethploreToken))
        urlComponent?.queryItems = params
        
        let urlRequest = assembleRequest(components:urlComponent!)
        
        let datatask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let safeData = data {
                    //create accounts
                    let ethexploreWallet = try self.parseEthploreWallet(data: safeData)
                    self.processEthploreAccounts(ethplorerObject: ethexploreWallet, institution: institution)
                } else {
                    log.error("Ethplore Error: \(String(describing: error))")
                    log.error("Ethplore Data: \(String(describing: data))")
                }
                async {
                    completion(false, error)
                }
            }
            catch {
                log.error("Failed to Ethplore wallet data: \(error)")
                async {
                    completion(false, error)
                }
            }
        }
        datatask.resume()
    }
    
    // MARK: - Private -
    
    fileprivate func authenticate(name: String, address: String, existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) throws {
        self.address = address
        self.name = name
        
        let addressURL = EthplorerUrl.appendingPathComponent("\(Commands.getAddressInfo.rawValue)/\(address)")
        var urlComponent = URLComponents(url: addressURL, resolvingAgainstBaseURL: false)
        var params = [URLQueryItem]()
        params.append(URLQueryItem(name: "apiKey", value: ethploreToken))
        urlComponent?.queryItems = params
        
        let urlRequest = assembleRequest(components:urlComponent!)
        
        let datatask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let safeData = data {
                    
                    if let _ = self.findError(data: safeData) {
                        throw EthplorerApi.CredentialsError.incorrectLoginCredentials
                    }
                    
                    if let existingInstitution = existingInstitution {
                        existingInstitution.address = address
                        async {
                            closeBlock(true, nil, existingInstitution)
                        }
                    } else {
                        //create institution
                        if let institution = InstitutionRepository.si.institution(source: .ethplorer, sourceInstitutionId: "", name: "\(name)") {
                            institution.address = address
                            
                            //create accounts
                            let ethexploreWallet = try self.parseEthploreWallet(data: safeData)
                            self.processEthploreAccounts(ethplorerObject: ethexploreWallet, institution: institution)
                            
                            async {
                                closeBlock(true, nil, institution)
                            }
                        } else {
                            throw "Error creating institution"
                        }
                    }
                } else {
                    log.error("Ethplore Error: \(String(describing: error))")
                    log.error("Ethplore Data: \(String(describing: data))")
                    throw EthplorerApi.CredentialsError.bodyNotValidJSON
                }
            }
            catch {
                log.error("Failed to Ethplore wallet data: \(error)")
                async {
                    closeBlock(false, error, nil)
                }
            }
        }
        datatask.resume()
	}
    
    fileprivate func processEthploreAccounts(ethplorerObject: EthplorerAccountObject, institution: Institution) {
        let responseAccounts = ethplorerObject.ethplorerAccounts
        for localAccount in responseAccounts {
            // Create or upload the local account object
            localAccount.updateLocalAccount(institution: institution)
        }
        
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in accounts {
            let index = responseAccounts.index(where: {$0.currency.code == account.currency})
            if index == nil {
                // This account doesn't exist in the response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
    
    fileprivate func parseEthploreWallet(data: Data) throws -> EthplorerAccountObject {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
            throw EthplorerApi.CredentialsError.bodyNotValidJSON
        }
        let ethplorerAccount = try EthplorerAccountObject(dictionary: dict, currencyShortName: "ETH", type: .wallet)
        return ethplorerAccount
    }
    
    fileprivate func findError(data: Data) -> String? {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
                throw EthplorerApi.CredentialsError.bodyNotValidJSON
            }
            if dict.keys.count == 1 {
                if let errorDict = dict["error"] {
                    return errorDict as? String
                }
            }
        } catch {
            return nil
        }
        return nil
    }
    
    fileprivate func assembleRequest(components: URLComponents) -> URLRequest {
        var request = URLRequest(url:components.url!)
        request.httpMethod = HTTPMethod.GET
        return request
    }
    
    
}

 extension EthplorerAccount {
    var balance: Int {
        let balance = available.integerFixedCryptoDecimals()
        return balance
    }
    
    var altBalance: Int? {
        if let altRate = altRate, let altCurrency = altCurrency {
            let altBalance = altRate * available
            let balance = altBalance.integerValueWith(decimals: altCurrency.decimals)
            return balance
        }
        return nil
    }
    
    @discardableResult func updateLocalAccount(institution: Institution) -> Account? {
        // Calculate the integer value of the balance based on the decimals
        if let newAccount = AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: currency.code, sourceInstitutionId: "", accountTypeId: .wallet, accountSubTypeId: nil, name: currency.name, currency: currency.code, currentBalance: balance, availableBalance: nil, number: nil, altCurrency: altCurrency?.code, altCurrentBalance: altBalance, altAvailableBalance: nil) {
            return newAccount
        }
        return nil
    }
}

extension Institution {
    fileprivate var addressKey: String { return "address institutionId: \(institutionId)" }
    var address: String? {
        get {
            return keychain[addressKey, "address"]
        }
        set {
            log.debug("set addressKey: \(addressKey)  newValue: \(String(describing: newValue))")
            keychain[addressKey, "address"] = address
        }
    }
}

