//
//  AddFeed.swift
//  Bal
//
//  Created by Jamie Rumbelow on 14/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest

class AddFeed: BaseTestCase {
    
    // Scenario: Add a new feed
    //   Given I am an established Balance user
    //   When I click on the preferences cog
    //     And I click on "Preferences"
    //     And I click on the "Rules" tab
    //     And I ensure there are no rule templates
    //     And I click on "Add a rule"
    //     And I select "Category name"
    //     And I select "Food and Drink"
    //   Then the rule name should be "In category \"Food and Drink\""
    //   When I click on the main dialog's "Feed" tab
    //   Then I should only have one transaction
    //     And the header should read "TUESDAY AUG 16 2016"
    //     And the transaction should be "Roedbyputtgarden for $13.07 in Ultimate Rewards Credit Card"
    
    func testAddFeed() {
        let app = self.app()
        
        self.loadPreferencesModal()
        app.windows["General"].toolbars.buttons["Rules"].click()
        
        let rulesWindow = app.windows["Rules"]
        let rulesTable = rulesWindow.tables["Rules Table"]
        let newRuleCell = rulesTable.cells["Rule: New Rule"]
        
        newRuleCell.buttons["Delete Rule"].click()
        
        rulesWindow.buttons["Add a Rule"].click()
        newRuleCell.buttons["Rule Field"].click()
        
        let newRuleDescription = newRuleCell.staticTexts["Rule Name"]
        self.waitForElementToAppear(newRuleDescription)
        XCTAssert(newRuleDescription.value as! String == "New Rule")
        
        // Category Name
        newRuleCell.scrollViews.otherElements.children(matching: .textField).element(boundBy: 1).click()
        
        newRuleCell.buttons["Add condition"].click()
        newRuleCell.buttons["Category Names"].click()
        
        let defaultFeedDescription = newRuleCell.staticTexts["Rule Name"]
        self.waitForElementToAppear(defaultFeedDescription)
        XCTAssert(defaultFeedDescription.value as! String == "In category \"Bank Fees\"") // default
        
        // Food and Drink
        newRuleCell.scrollViews.otherElements.children(matching: .textField).element(boundBy: 3).click()
        
        let feedDescription = newRuleCell.staticTexts["Rule Name"]
        self.waitForElementToAppear(feedDescription)
        XCTAssert(feedDescription.value as! String == "In category \"Food and Drink\"")
        
        app.buttons["Feed"].click()
        
        let feedTable = app.tables["Feed List"]
        self.waitForElementToAppear(feedTable)
        
        let transactionHeaderView = feedTable.cells.element(boundBy: 0)
        let transactionRowView = feedTable.cells.element(boundBy: 1)
        
        // There should only be one row for this filter (mostly why I chose it!)
        // Which means there will be two cells; the date header and the transaction row itself
        
        XCTAssert(feedTable.cells.count == 2)
        XCTAssert(transactionHeaderView.staticTexts.element(boundBy: 0).value as! String == "TUESDAY AUG 16 2016")
        XCTAssert(transactionRowView.staticTexts.element(boundBy: 0).value as! String == "Roedbyputtgarden for $13.07 in Ultimate Rewards Credit Card")        
    }
    
}
