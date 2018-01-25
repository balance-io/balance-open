//
//  Debugging.swift
//  Bal
//
//  Created by Benjamin Baron on 4/29/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCGLogger

// Options for release build
let betaOptionsEnabled = false
let betaExpirationDateComponents = DateComponents(year: 2017, month: 3, day: 9)

#if DEBUG
    
/***********************************************************************
 These apply to Xcode builds. NEVER EDIT THESE, USE THE USER DEFAULTS. That means you Richard ;)
 ***********************************************************************/
    
class Debugging {
    var logAccessTokens: Bool {
        return true
    }
    
    var logRealmCredentials: Bool {
        return true
    }
    
    var logZepherActivity: Bool {
        if let logZepherActivity = UserDefaults.standard.object(forKey: "logZepherActivity") as? Bool {
            return logZepherActivity
        }
        return false
    }
    
    var printRawPlaidConnections: Bool {
        return true
    }
    
    var defaultToTransactionsTab: Bool {
        if let defaultToTransactionsTab = UserDefaults.standard.object(forKey: "defaultToTransactionsTab") as? Bool {
            return defaultToTransactionsTab
        }
        return false
    }
    
    var defaultToInsightsTab: Bool {
        if let defaultToInsightsTab = UserDefaults.standard.object(forKey: "defaultToInsightsTab") as? Bool {
            return defaultToInsightsTab
        }
        return false
    }
    
    var showInstitutionTypesInSearch: Bool {
        if let showInstitutionTypesInSearch = UserDefaults.standard.object(forKey: "showInstitutionTypesInSearch") as? Bool {
            return showInstitutionTypesInSearch
        }
        return false
    }
    
    var viewFontsAsYosemite: Bool {
        if let viewFontsAsYosemite = UserDefaults.standard.object(forKey: "viewFontsAsYosemite") as? Bool {
            return viewFontsAsYosemite
        }
        return false
    }
    
    var showAddAccountsOnLaunch: Bool {
        if let showAddAccountsOnLaunch = UserDefaults.standard.object(forKey: "showAddAccountsOnLaunch") as? Bool {
            return showAddAccountsOnLaunch
        }
        return false
    }
    
    var useMockSyncing: Bool {
        if let useMockSyncing = UserDefaults.standard.object(forKey: "useMockSyncing") as? Bool {
            return useMockSyncing
        }
        return false
    }

    var useMockSession: Bool {
        if let useMockSession = UserDefaults.standard.object(forKey: "useMockSession") as? Bool {
            return useMockSession
        }
        return false
    }
    
    var keepPopoverPinned: Bool {
        if let keepPopoverPinned = UserDefaults.standard.object(forKey: "keepPopoverPinned") as? Bool {
            return keepPopoverPinned
        }
        return false
    }
    
    var fastLaunch: Bool {
        if let fastLaunch = UserDefaults.standard.object(forKey: "fastLaunch") as? Bool {
            return fastLaunch
        }
        return false
    }
    
    var showRulesPreferencesOnLaunch: Bool {
        if let showRulesPreferencesOnLaunch = UserDefaults.standard.object(forKey: "showRulesPreferencesOnLaunch") as? Bool {
            return showRulesPreferencesOnLaunch
        }
        return false
    }

    var showSecurityPreferencesOnLaunch: Bool {
        if let showSecurityPreferencesOnLaunch = UserDefaults.standard.object(forKey: "showSecurityPreferencesOnLaunch") as? Bool {
            return showSecurityPreferencesOnLaunch
        }
        return false
    }
    
    var showBillingPreferencesOnLaunch: Bool {
        if let showBillingPreferencesOnLaunch = UserDefaults.standard.object(forKey: "showBillingPreferencesOnLaunch") as? Bool {
            return showBillingPreferencesOnLaunch
        }
        return false
    }
    
    var showAllInstitutionsAsIncorrectPassword: Bool {
        if let showAllInstitutionsAsIncorrectPassword = UserDefaults.standard.object(forKey: "showAllInstitutionsAsIncorrectPassword") as? Bool {
            return showAllInstitutionsAsIncorrectPassword
        }
        return false
    }
    
    var fakeTouchId: Bool {
        if let fakeTouchId = UserDefaults.standard.object(forKey: "fakeTouchId") as? Bool {
            return fakeTouchId
        }
        return false
    }
    
    var showSearchBarForInsights: Bool {
        return false
    }
    
    var showSearchBarForFeed: Bool {
        return false
    }
    
    var betaExpired: Bool {
        return false
    }
    
    var useLocalSubscriptionServer: Bool {
        if let useLocalSubscriptionServer = UserDefaults.standard.object(forKey: "useLocalSubscriptionServer") as? Bool {
            return useLocalSubscriptionServer
        }
        return false
    }
    
    var useLocalRealmServer: Bool {
        if let useLocalRealmServer = UserDefaults.standard.object(forKey: "useLocalRealmServer") as? Bool {
            return useLocalRealmServer
        }
        return false
    }
    
    var personalAppStoreReceipt: String {
        if let personalAppStoreReceipt = UserDefaults.standard.object(forKey: "personalAppStoreReceipt") as? String {
            return personalAppStoreReceipt
        }
        return ""
    }
    
    var logLevel: XCGLogger.Level {
        if let logLevel = UserDefaults.standard.object(forKey: "logLevel") as? Int, let level = XCGLogger.Level(rawValue: logLevel) {
            return level
        }
        return .debug
    }
}

#else
    
/****************************************************************************
 These are for the Release mode, NEVER EDIT THESE! THEY SHOULD ALL BE FALSE!!
 ****************************************************************************/
    
class Debugging {
    var logAccessTokens: Bool {
        return false
    }
    
    var logRealmCredentials: Bool {
        return false
    }
    
    var logZepherActivity: Bool {
        if let logZepherActivity = UserDefaults.standard.object(forKey: "logZepherActivity") as? Bool {
            return logZepherActivity
        }
        return false
    }
    
    var printRawPlaidConnections: Bool {
        return false
    }
    
    var defaultToTransactionsTab: Bool {
        return false
    }
    
    var defaultToInsightsTab: Bool {
        return false
    }
    
    var showInstitutionTypesInSearch: Bool {
        if let showInstitutionTypesInSearch = UserDefaults.standard.object(forKey: "showInstitutionTypesInSearch") as? Bool {
            return showInstitutionTypesInSearch
        }
        return false
    }
    
    var viewFontsAsYosemite: Bool {
        return false
    }
    
    var showAddAccountsOnLaunch: Bool {
        return false
    }
    
    var useMockSyncing: Bool {
        return false
    }
    
    var useMockSession: Bool {
        return false
    }
    
    var keepPopoverPinned: Bool {
        if let keepPopoverPinned = UserDefaults.standard.object(forKey: "keepPopoverPinned") as? Bool {
            return keepPopoverPinned
        }
        return false
    }
    
    var fastLaunch: Bool {
        if let fastLaunch = UserDefaults.standard.object(forKey: "fastLaunch") as? Bool {
            return fastLaunch
        }
        return false
    }
    
    var showRulesPreferencesOnLaunch: Bool {
        return false
    }
    
    var showSecurityPreferencesOnLaunch: Bool {
        return false
    }
    
    var showBillingPreferencesOnLaunch: Bool {
        return false
    }
    
    var showAllInstitutionsAsIncorrectPassword: Bool {
        return false
    }

    var fakeTouchId: Bool {
        return false
    }
    
    var showSearchBarForInsights: Bool {
        return false
    }
    
    var showSearchBarForFeed: Bool {
        return false
    }
    
    var betaExpired: Bool {
        if betaOptionsEnabled {
            if let expirationDate = Calendar.current.date(from: betaExpirationDateComponents) {
                let timeInterval = Date().timeIntervalSince(expirationDate)
                return timeInterval > 0.0
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    var useLocalSubscriptionServer: Bool {
        return false
    }
    
    var useLocalRealmServer: Bool {
        return false
    }
    
    var enablePlaidPatchWorkaround: Bool {
        return false
    }
    
    var usePersonalAppStoreReceipt: Bool {
        return false
    }
    
    var logLevel: XCGLogger.Level {
        return .info
    }
}

#endif

func debugPrintInstitutionKeys() {
    #if DEBUG
        guard !Testing.runningUiTests && debugging.logAccessTokens else {
            return
        }
        
        for institution in InstitutionRepository.si.allInstitutions() {
            if let accessToken = institution.accessToken {
                log.debug("(\(institution)): accessToken: \(accessToken)")
                if let refreshToken = institution.refreshToken {
                    log.debug("(\(institution)): refreshToken: \(refreshToken)")
                }
            }
        }
    #endif
}
