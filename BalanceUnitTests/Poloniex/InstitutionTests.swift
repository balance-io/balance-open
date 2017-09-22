//
//  InstitutionTests.swift
//  BalanceOpenTests
//
//  Created by Raimon Lapuente on 08/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

// Tests won't work until we enable de database for testing
// then we just add test before each func name

class InstitutionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        InstitutionRepository.si.allInstitutions().forEach { (institution) in
            institution.delete()
        }
        super.tearDown()
    }

    func InstitutionCreation() {
        //given
        let institution = InstitutionRepository.si.institution(source: .poloniex, sourceInstitutionId: "", name: "Poloniex")
        
        //then
        XCTAssertEqual(institution?.name, "Poloniex")
    }

    func InstitutionStorage() {
        //given
        InstitutionRepository.si.institution(source: .poloniex, sourceInstitutionId: "", name: "Poloniex")

        //then
        let institutionsFromMemory = InstitutionRepository.si.allInstitutions()
        let institution = institutionsFromMemory.first
        XCTAssertEqual(institution?.name, "Poloniex")
    }

    func PoloniexCredentials() {
        //given
        let institution = InstitutionRepository.si.institution(source: .poloniex, sourceInstitutionId: "", name: "Poloniex")
        XCTAssertNil(institution?.apiKey)
        XCTAssertNil(institution?.secret)
        
        //when
        institution?.apiKey = "key"
        institution?.secret = "somesecret"
        
        //then
        XCTAssertEqual(institution?.apiKey, "key")
        XCTAssertEqual(institution?.secret, "somesecret")
    }
}
