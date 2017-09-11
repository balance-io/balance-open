//
//  RearrangeAccounts.swift
//  Bal
//
//  Created by Jamie Rumbelow on 09/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest

// Feature: Rearrange accounts
//   In order to organise my account balances by personal priority
//   As a user
//   I want arrange and order my accounts and institutions

class RearrangeAccounts: BaseTestCase {
    
    // Scenario: Rearrange institutions through accounts tab
    //   Given I am an established Balance user
    //     And I have more than one account from more than one institution
    //   When I click and hold my mouse on the coloured instituion name bar
    //     And I drag the first account down to below the second institution
    //     And I release my mouse click
    //   Then my institutions should be in the expected order
    
    func testRearrangeInstitutions() {
        let app = self.app()
        
        // This is quite awkward. In order to test the ordering of the institutions
        // in the list, we need to reorder through the UI first, then build up a local array,
        // which maps the institutions on the screen. Then we can check that their indexes are adjacent.
        
        let institution = app.tables["Accounts Table"].cells["Section: Chase"]
        let lowerInstitution = app.tables["Accounts Table"].cells["Section: PayPal"]
        
        // Reorder
        institution.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .click(forDuration: TimeInterval(integerLiteral: 2), thenDragTo: lowerInstitution.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -0.05)))
        
        // Now generate the local array and assert the indexes.
        
        let institutions = app.tables["Accounts Table"].cells.allElementsBoundByIndex.flatMap({ (val) -> String in
            let texts = val.staticTexts.matching(NSPredicate(format: "label LIKE 'Institution Name'"))
            
            return ( texts.count > 0 ) ? texts.element.value as! String : ""
        })
        .filter({ $0 != "" })
    
        let chaseI = institutions.index(of: "Chase")!
        let paypalI = institutions.index(of: "PayPal")!
        
        XCTAssert(app.tables.tableRows.containing(.staticText, identifier: "Chase") != app.tables.tableRows.element(boundBy: 0))
        XCTAssert(abs(chaseI - paypalI) == 1, "Index for Chase (\(chaseI)) - PayPal (\(paypalI)) != 1")
    }
    
    // Scenario: Rearrange accounts through accounts tab
    //   Given I am an established Balance user
    //     And I have more than one account from the same institution
    //   When I click and hold my mouse on the account name
    //     And I drag the first account down to below the second account
    //     And I release my mouse click
    //   Then my accounts should be in the expected order
    
    func testRearrangeAccountsAccountsTab() {
        let app = self.app()
        
        let accountOne = app.tables["Accounts Table"].cells["Savings/Plus"]
        let belowInstitution = app.tables["Accounts Table"].cells["Section: American Express"]
        
        // Reorder
        accountOne.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            .click(forDuration: TimeInterval(integerLiteral: 2), thenDragTo: belowInstitution.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)))
        
        // Now generate the local array and assert the indexes.
        
        let accounts = app.tables["Accounts Table"].cells.allElementsBoundByIndex.flatMap({ (val) -> String in
            let texts = val.staticTexts.matching(NSPredicate(format: "label LIKE 'Account Name'"))
            
            return ( texts.count > 0 ) ? texts.element.value as! String : ""
        })
        .filter({ $0 != "" })

        let accountOneI = accounts.index(of: "Savings/Plus")!
        let accountTwoI = accounts.index(of: "Used Auto Loan")!

        XCTAssert(app.tables.tableRows.containing(.staticText, identifier: "Savings/Plus") != app.tables.tableRows.element(boundBy: 3))
        XCTAssert(abs(accountOneI - accountTwoI) == 1, "Index for 'Savings/Plus' (\(accountOneI)) - 'Used Auto Loan' (\(accountTwoI)) equals \(accountOneI - accountTwoI), not 1")
    }
    
}
