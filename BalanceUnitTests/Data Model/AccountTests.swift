//
//  AccountTests.swift
//  BalanceUnitTests
//
//  Created by Raimon Lapuente Ferran on 24/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
import Foundation

@testable import BalancemacOS

class AccountTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAccountCreation() {
        // given
        defaults.masterCurrency = .btc
        let account = Account.init(accountId: 659, institutionId: 9, source: .poloniex, sourceAccountId: "SYS", sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: "Syscoin", currency: "SYS", currentBalance: 89825000000, availableBalance: nil, number: nil, altCurrency: "BTC", altCurrentBalance: 2493450, altAvailableBalance: nil, repository: AccountRepository.si)
        
        // then
        XCTAssertNotNil(account.masterAltCurrentBalance)
        XCTAssertNotNil(account.displayAltBalance)
        XCTAssertNotNil(account.displayBalance)
        XCTAssertNotNil(account.displayName)
    }
    
    func testAccountWith0AmountReturns0() {
        // given
        let account = Account.init(accountId: 659, institutionId: 9, source: .poloniex, sourceAccountId: "SYS", sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: "Syscoin", currency: "SYS", currentBalance: 0, availableBalance: nil, number: nil, altCurrency: "BTC", altCurrentBalance: 0, altAvailableBalance: nil, repository: AccountRepository.si)
        
        // then
        XCTAssertEqual(account.masterAltCurrentBalance, 0)
        XCTAssertEqual(account.masterAltAvailableBalance, nil)
        XCTAssertEqual(account.displayAltBalance, 0)
        XCTAssertEqual(account.displayBalance, 0)
    }
    
    func testAccountConversionToEuro() {
        
        // given
        defaults.masterCurrency = .eur
        let account = Account.init(accountId: 659, institutionId: 9, source: .poloniex, sourceAccountId: "SYS", sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: "Syscoin", currency: "SYS", currentBalance: 89825000000, availableBalance: nil, number: nil, altCurrency: "BTC", altCurrentBalance: 2493450, altAvailableBalance: nil, repository: AccountRepository.si)
        
        // then
        XCTAssertEqual(account.masterAltCurrentBalance, nil)
        XCTAssertEqual(account.masterAltAvailableBalance, nil)
        XCTAssertEqual(account.displayAltBalance, nil)
        XCTAssertEqual(account.displayBalance, nil)
        XCTAssertEqual(account.displayName, nil)
    }
}
