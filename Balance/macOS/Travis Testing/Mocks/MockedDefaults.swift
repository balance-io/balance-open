//
//  MockedDefaults.swift
//  Bal
//
//  Created by Jamie Rumbelow on 13/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class MockedDefaults: Defaults {
    override func setupDefaults() {
        let dict: [String: Any] = [Keys.crashOnExceptions:                 true,
                                   Keys.launchAtLogin:               true,
                                   Keys.accountIdsExcludedFromTotal: NSArray(),
                                   Keys.firstLaunch:                 false,
                                   Keys.selectedThemeType:           ThemeType.light.rawValue]
        defaults.register(defaults: dict)
    }
}
