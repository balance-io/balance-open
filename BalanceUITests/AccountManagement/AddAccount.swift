//
//  AccountManagementTestCase.swift
//  Bal
//
//  Created by Jamie Rumbelow on 29/08/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest

// Feature: Add account
//   In order to see my transactions and account data
//   As a user
//   I want add accounts

class AccountManagementTestCase: BaseTestCase {
    
    // Scenario: Add account through welcome screen (button)
    //   Given I am a new Balance user
    //   When I click on "PayPal"
    //     And I enter my PayPal email address
    //     And I enter my PayPal password
    //     And I click "Connect"
    //   Then my account should be added
    
    func testAddAccountThroughWelcomeScreen() {
        let login = self._testAccount()
        let app = self.emptyApp(login)
        
        app.buttons["PayPal"].click()
        app.textFields["john@apple.com"].typeText(login["TEST_ACCOUNT_EMAIL"]!)
        app.secureTextFields["password"].click()
        app.secureTextFields["password"].typeText(login["TEST_ACCOUNT_PASSWORD"]!)
        app.buttons["Connect"].click()
        
        let paypalCell = app.scrollViews.tables.tableRows.cells.staticTexts["PayPal Account"]
        self.waitForElementToAppear(paypalCell, seconds: 30)
    }
    
    // Scenario: Add account through welcome screen (search)
    //   Given I am a new Balance user
    //   When I click on the search institutions field
    //     And I type "paypal"
    //     And I click on "PayPal"
    //     And I enter my PayPal email address
    //     And I enter my PayPal password
    //     And I click "Connect"
    //   Then my account should be added
    
    func testAddAccountThroughWelcomeScreenSearch() {
        let login = self._testAccount()
        let app = self.emptyApp(login)
        
        let searchField = app.searchFields["Institution Search"]
        searchField.click()
        searchField.typeText("paypal")
        
        let paypalListingCell = app.scrollViews.tables.tableRows.cells.staticTexts["PayPal"]
        self.waitForElementToAppear(paypalListingCell, seconds: 15)
        
        app.tables.staticTexts["PayPal"].click()
        
        app.textFields["john@apple.com"].typeText(login["TEST_ACCOUNT_EMAIL"]!)
        app.secureTextFields["password"].click()
        app.secureTextFields["password"].typeText(login["TEST_ACCOUNT_PASSWORD"]!)
        app.buttons["Connect"].click()
        
        let paypalCell = app.scrollViews.tables.tableRows.cells.staticTexts["PayPal Account"]
        self.waitForElementToAppear(paypalCell, seconds: 30)
    }
    

//    TODO: Can't get following test to run; UI recorder won't record menu bar items
//          and I can't find it through the code.
    
    
    
    // Scenario: Add account screen
    //   Given I am an established Balance user
    //   When I click on preferences button
    //     And I click on "Add an account"
    //   Then I should be on the add account screen
//    
//    func testAddAccountThroughAddAccountScreen() {
//        let app = self.app()
//        
//        menuBarItem.click()
//        
//        app.dialogs.buttons["Preferences"].click()
//        app.menuItems["Add an account"].click()
//        
//        let addAnAccountHeader = app.staticTexts["Add an Account"]
//        self.waitForElementToAppear(addAnAccountHeader, seconds: 30)
//        let institutionSearch = app.searchFields["Institution Search"]
//        self.waitForElementToAppear(institutionSearch, seconds: 30)
//    }
    
    
    // Scenario: Add account through preferences modal
    //   Given I am an established Balance user
    //   When I click on the preferences cog
    //     And I click on "Preferences"
    //     And I click on the "Accounts" tab
    //     And I click on "Add a new login"
    //   Then I should be on the add account screen
    
    func testAddAccountThroughAddAccountScreen() {
        let app = self.app()

        self.loadPreferencesModal()
        
        app.windows["General"].toolbars.buttons["Accounts"].click()
        app.windows["Accounts"].buttons["Add a new login"].click()

        let addAnAccountHeader = app.staticTexts["Add an Account"]
        self.waitForElementToAppear(addAnAccountHeader, seconds: 30)
        let institutionSearch = app.searchFields["Institution Search"]
        self.waitForElementToAppear(institutionSearch, seconds: 30)
    }
    
    
    
    
    
    // Scenario: Add account validation error
    //   Given I am an established Balance user
    //     And I am on the add account screen
    //   When I click on "PayPal"
    //     And I enter a random email address
    //     And I enter a random password
    //     And I click "Connect"
    //   Then my account should not be added
    //     And I should see an error message
    
    func testAddAccountValidationError() {
        let app = self.emptyApp()
        let randomEmail = "randomemail@randomtest.com"
                
        app.buttons["PayPal"].click()
        app.textFields["john@apple.com"].typeText(randomEmail)
        app.secureTextFields["password"].click()
        app.secureTextFields["password"].typeText("r4nd0mPassworD")
        app.buttons["Connect"].click()
        
        // @todo Turn into mocked API request
        
        let errorMsg = app.staticTexts.element(matching: NSPredicate(format: "value like 'Connection issue:*'"))
        
        self.waitForElementToAppear(errorMsg, seconds: 15)
        XCTAssert(app.buttons["Connect"].exists == true)
        XCTAssert(app.textFields["john@apple.com"].value as! String == randomEmail)
    }
    
    func _testAccount() -> [String: String] {
        return [
            "TEST_ACCOUNT": "1",
            "TEST_ACCOUNT_EMAIL": "jamie+testbalance@jamierumbelow.net",
            "TEST_ACCOUNT_PASSWORD": "BalanceTest2016"
        ]
    }
    
}
