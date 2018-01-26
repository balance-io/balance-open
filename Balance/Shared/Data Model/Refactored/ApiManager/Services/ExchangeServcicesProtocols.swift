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
    func processAccounts(for source: Source, accounts: [ExchangeAccount], institution: ExchangeInstitution)
    func processTransactions(for source: Source, transactions: [ExchangeTransaction])
}

protocol KeychainServiceProtocol: class {
    func save(identifier: String, value: [String: Any]) throws
    func save(account: String, key: String, value: String)
    func fetch(account: String, key: String) -> String?
}
