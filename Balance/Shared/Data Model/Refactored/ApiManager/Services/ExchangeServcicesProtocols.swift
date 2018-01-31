//
//  ExchangeServcicesProtocols.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol RepositoryServiceProtocol {
    func createInstitution(for source: Source) -> Institution?
    func createAccounts(for source: Source, accounts: [ExchangeAccount], institution: Institution)
    func createTransactions(for source: Source, transactions: [ExchangeTransaction])
}

protocol KeychainServiceProtocol: class {
    func save(source: Source, identifier: String, credentials: Credentials)
    func fetch(account: String, key: String) -> String?
    func fetchCredentials(with identifer: String, source: Source) -> Credentials?
}
