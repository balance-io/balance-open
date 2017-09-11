//
//  AccountCell.swift
//  Bal
//
//  Created by Jamie Rumbelow on 08/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest

// Feature: Account cell
//   In order to interact with my saved accounts quickly and easily
//   As a user
//   I want be able to expand the account cell and use its functionality

class AccountCell: BaseTestCase {
    
    // Scenario: Expand account cell
    //   Given I am an established Balance user
    //     And I have more than one account
    //   When I click on one of my account cells
    //   Then it should be expanded
    
    func testExpandAccountCell() {
        let app = self.app()
        
        let cell = app.tables["Accounts Table"].cells["Ultimate Rewards Credit Card"]
        cell.click()
        
        self.waitForElementToAppear(cell.buttons["Search transactions"])
        self.waitForElementToAppear(cell.staticTexts["Transaction details"])
        
        XCTAssert(cell.staticTexts["Transaction details"].value as! String =~ "^([0-9]+) transactions")
    }
    
    // Scenario: Go to transactions
    //   Given I am an established Balance user
    //     And I have more than one account
    //   When I click on one of my account cells
    //     And I click on "Search transactions"
    //   Then I should be on the transactions list
    //     And the transactions search should be scoped to that account
    
    func testGoToTransactions() {
        let app = self.app()
        
        let cell = app.tables.cells["Ultimate Rewards Credit Card"]
        cell.click()
        cell.buttons["Search transactions"].click()
        
        let transactionsCount = app.dialogs.descendants(matching: .staticText).matching(NSPredicate(format: "value MATCHES '([0-9]+) TRANSACTIONS'")).element
        self.waitForElementToAppear(transactionsCount)
        
        XCTAssert(app.buttons["Transactions"].isSelected)
        
        let searchSearchField = app.searchFields.containing(.button, identifier:"Search").element
        XCTAssert(searchSearchField.exists)
        XCTAssert(searchSearchField.value as! String =~ "^in:\\(Ultimate Rewards Credit Card\\)")
    }
    
    // Scenario: Exclude from balance
    //   Given I am an established Balance user
    //     And I have more than one account
    //   When I click on one of my account cells
    //     And I click on "Exclude balance"
    //   Then I should see the excluded icon
    //     And I should see an "Include balance button"
    //     And my total balance should be reduced by the amount in that account
    //   When I click on an already excluded account
    //     And I click on "Include balance"
    //   Then I shouldn't see the excluded icon
    //     And my total balance should be increased by the amount

    func testExcludeAndIncludeFromBalance() {
        let app = self.app()
        
        let total = self._convertCurrencyStringToFloat(app.staticTexts["Total Balance"].value as! String)!
        print(total.debugDescription)
        let cell = app.tables.cells["Ultimate Rewards Credit Card"]
        
        cell.click()
        
        let accountTotal = self._convertCurrencyStringToFloat(cell.staticTexts["Account Total"].value as! String)!
        let exclude = cell.buttons["Exclude balance"]
        
        exclude.click()
        
        let include = cell.buttons["Include balance"]
        self.waitForElementToAppear(include)
        
        let excludedTotal = self._convertCurrencyStringToFloat(app.staticTexts["Total Balance"].value as! String)!
        
        XCTAssert(cell.images["Account included in total?"].exists)
        XCTAssert(excludedTotal == total.subtracting(accountTotal), "new total (\(excludedTotal.stringValue)) didn't match old total (\(total.stringValue)) - account total (\(accountTotal.stringValue))")
        
        include.click()
        self.waitForElementToAppear(exclude)
        
        let includedTotal = self._convertCurrencyStringToFloat(app.staticTexts["Total Balance"].value as! String)!
        
        XCTAssert(!cell.images["CircleRemove"].exists)
        XCTAssert(includedTotal.floatValue == total.floatValue)
    }
    
}
