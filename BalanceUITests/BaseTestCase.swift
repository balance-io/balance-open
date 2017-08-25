//
//  BaseTestCase.swift
//  Bal
//
//  Created by Jamie Rumbelow on 23/08/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import XCTest

class BaseTestCase: XCTestCase {
    
    let app = XCUIApplication()
    var menuBarItem: XCUIElement {
        return app.children(matching: .menuBar).element(boundBy: 1).menuBarItems["Balance"]
    }
    
    override func tearDown() {
        super.tearDown()
        
        app.terminate()
    }
    
    /**
     * Return an instance of XCUIApplication, set to load from a clean database
     *
     * @todo Document
     */
    func emptyApp(_ options: [String: String]? = nil) -> XCUIApplication {
        var defaults = [ "USE_CLEAN_DB": "1" ]
        defaults.update(options)
        
        return self.app(defaults)
    }
    
    func app(_ options: [String: String]? = nil) -> XCUIApplication {
        continueAfterFailure = false
        
        app.launchEnvironment["RUNNING_UI_TESTS"] = "1"
        
        if options != nil {
            app.launchEnvironment.update(options!)
        }
        
        app.launch()
        
        return app
    }
    
    func loadPreferencesModal() {
        app.dialogs.buttons["Preferences"].click()
        app.tables.containing(.tableColumn, identifier:"main").element.typeKey(",", modifierFlags:.command)
    }
    
    func _convertCurrencyStringToFloat(_ string: String) -> NSDecimalNumber? {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.init(identifier: "en_US")
        
        if string.contains("$") {
            formatter.numberStyle = .currency
        }
        else {
            formatter.numberStyle = .decimal
        }
        
        return NSDecimalNumber(decimal: formatter.number(from: string)!.decimalValue)
    }
    
    //
    // Thanks – http://masilotti.com/xctest-helpers/
    //
    
    func waitForElementToAppear(_ element: XCUIElement,
                                seconds: Double = 5,
                                        file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate,
                                evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: seconds) { (error) -> Void in
            if (error != nil) {
                print(self.app.debugDescription)
                let message = "Failed to find \(element) after \(seconds) seconds."
                self.recordFailure(withDescription: message,
                                                  inFile: file, atLine: line, expected: true)
            }
        }
    }
}
