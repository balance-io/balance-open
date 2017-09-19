//
//  EthplorerApi.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith

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
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        assert(loginStrings.count == 2, "number of auth fields should be 2 for Ethplorer")
        var nameField : String?
        var addressField : String?
        for field in loginStrings {
            if field.type == "name" {
                nameField = field.value
            } else if field.type == "address" {
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
            try authenticate(name: name, address: address, closeBlock: closeBlock)
        } catch {
            
        }
    }
    
    func fetchAddressInfo(institution: Institution, completion: @escaping SuccessErrorBlock) {
        guard let address = institution.address else {
            assert(false, "Address shouldn't be nil")
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
                    print("Ethplore Error: \(String(describing: error))")
                    print("Ethplore Data: \(String(describing: data))")
                }
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
            catch {
                log.error("Failed to Ethplore wallet data: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        datatask.resume()
    }
    
    // MARK: - Private -
    
    fileprivate func authenticate(name: String, address: String, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) throws {
        self.address = address
        self.name = name
        if let institution = InstitutionRepository.si.institution(source: .wallet, sourceInstitutionId: "", name: "\(name)") {
            institution.address = address
            
            self.fetchAddressInfo(institution: institution) { (finish, error) in
                async {
                    closeBlock(finish, error, institution)
                }
            }
        }
	}
    
    fileprivate func processEthploreAccounts(ethplorerObject: EthplorerAccountObject, institution: Institution) {
        let accounts = ethplorerObject.arrayOfEthplorerAccounts
        for localAccount in accounts {
            // Create or upload the local account object
            localAccount.updateLocalAccount(institution: institution)
        }
        
        let customAccounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in customAccounts {
            let index = customAccounts.index(where: {$0.currency == account.currency})
            if index == nil {
                // This account doesn't exist in the response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
    
    fileprivate func parseEthploreWallet(data: Data) throws -> EthplorerAccountObject {
        guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
            throw PoloniexApi.CredentialsError.bodyNotValidJSON
        }
        let ethplorerAccount = try EthplorerAccountObject.init(dictionary: dict, currencyShortName: "ETH", type: .wallet)
        return ethplorerAccount
    }
    
    fileprivate func findError(data: Data) -> String? {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                throw PoloniexApi.CredentialsError.bodyNotValidJSON
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
        request.httpMethod = "GET"
        return request
    }
    
    
}

 extension EthplorerAccount {
    var balance: Int {
        let balance = available.integerFixedCryptoDecimals()
        return balance
    }
    
    var altBalance: Int {
        let altValance = altRate * available
        let altBalance = altValance.integerFixedCryptoDecimals()
        return altBalance
    }
    
    @discardableResult func updateLocalAccount(institution: Institution) -> Account? {
        // Calculate the integer value of the balance based on the decimals
        let currentBalance = balance
        let altCurrentBalance = altBalance
        
        if let newAccount = AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: currency.name, sourceInstitutionId: "", accountTypeId: .wallet, accountSubTypeId: nil, name: currency.name, currency: currency.name, currentBalance: currentBalance, availableBalance: nil, number: nil, altCurrency: altCurrency.name, altCurrentBalance: altCurrentBalance, altAvailableBalance: nil) {
            
            // Hide unpoplular currencies that have a 0 balance
            if currency != Currency.btc && currency != Currency.eth {
                newAccount.isHidden = (currentBalance == 0)
            }
            
            return newAccount
        }
        return nil
    }
}

extension Institution {
    fileprivate var addressKey: String { return "address institutionId: \(institutionId)" }
    var address: String? {
        get {
            var address: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: addressKey) {
                address = dictionary["address"] as? String
            }
            
            print("get addressKey: \(addressKey)  address: \(String(describing: address))")
            if address == nil {
                // We should always be getting an address becasuse we never read it until after it's been written
                log.severe("Tried to read address for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return address
        }
        set {
            print("set addressKey: \(addressKey)  newValue: \(String(describing: newValue))")
            if let address = newValue {
                do {
                    try Locksmith.updateData(data: ["address": address], forUserAccount: addressKey)
                } catch {
                    log.severe("Couldn't update address keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if address != self.address {
                    log.severe("Saved addressKey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: addressKey)
                } catch {
                    log.severe("Couldn't delete address keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: addressKey)
                if dictionary != nil {
                    log.severe("Deleted address for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
}

