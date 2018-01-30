//
//  BtcApi.swift
//  Balance
//
//  Created by Raimon Lapuente Ferran on 30/01/2018.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BtcApi: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        assert(false,"Not implemented")
    }
    
    
}

//Helpers

extension BtcAccount {
    @discardableResult func updateLocalAccount(institution: Institution) -> Account? {
        // Calculate the integer value of the balance based on the decimals
        if let newAccount = AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: currency.code, sourceInstitutionId: "", accountTypeId: .wallet, accountSubTypeId: nil, name: currency.name, currency: currency.code, currentBalance: finalBalance, availableBalance: nil, number: nil, altCurrency: currency.code, altCurrentBalance: finalBalance, altAvailableBalance: nil) {
            return newAccount
        }
        return nil
    }
}
