//
//  Notifications.swift
//  Bal
//
//  Created by Benjamin Baron on 2/25/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct Notifications {
    static let InstitutionAdded                       = Notification.Name("InstitutionAdded")
    static let InstitutionRemoved                     = Notification.Name("InstitutionRemoved")
    static let SyncStarted                            = Notification.Name("SyncStarted")
    static let SyncingInstitution                     = Notification.Name("SyncingInstitution")
    static let SyncCompleted                          = Notification.Name("SyncCompleted")
    static let ShowAddAccount                         = Notification.Name("ShowAddAccount")
    static let ShowTabs                               = Notification.Name("ShowTabs")
    static let PerformSearch                          = Notification.Name("PerformSearch")
    static let ShowSearch                             = Notification.Name("ShowSearch")
    static let TogglePopover                          = Notification.Name("TogglePopover")
    static let ShowPopover                            = Notification.Name("ShowPopover")
    static let HidePopover                            = Notification.Name("HidePopover")
    static let AccountExcludedFromTotal               = Notification.Name("AccountExcludedFromTotal")
    static let AccountIncludedInTotal                 = Notification.Name("AccountIncludedInTotal")
    static let RulesChanged                           = Notification.Name("RulesChanged")
    static let ReloadPopoverController                = Notification.Name("ReloadPopoverController")
    static let PopoverWillShow                        = Notification.Name("PopoverWillShow")
    static let PopoverWillHide                        = Notification.Name("PopoverWillHide")
    static let ShowTabIndex                           = Notification.Name("ShowTabIndex")
    static let AccountAdded                           = Notification.Name("AccountAdded")
    static let AccountRemoved                         = Notification.Name("AccountRemoved")
    static let ProductPurchased                       = Notification.Name("ProductPurchased")
    static let UnreadNotificationIdsUpdatedFromCloud  = Notification.Name("UnreadNotificationIdsUpdatedFromCloud")
    static let LockUserInterface                      = Notification.Name("LockUserInterface")
    static let UnlockUserInterface                    = Notification.Name("UnlockUserInterface")
    static let ShowPatchAccount                       = Notification.Name("ShowPatchAccount")
    static let AccountPatched                         = Notification.Name("AccountPatched")
    static let NetworkBecameReachable                 = Notification.Name("NetworkBecameReachable")
    static let NetworkBecameUnreachable               = Notification.Name("NetworkBecameUnreachable")
    static let DisplayServerMessage                   = Notification.Name("DisplayServerMessage")
    static let SubscribeStarted                       = Notification.Name("SubscribeStarted")
    static let SubscribeFailed                        = Notification.Name("SubscribeFailed")
    static let AccountHidden                          = Notification.Name("AccountHidden")
    static let AccountUnhidden                        = Notification.Name("AccountUnhidden")
    static let RealmAuthenticated                     = Notification.Name("RealmAuthenticated")
    static let SyncError                              = Notification.Name("SyncError")
    
    struct Keys {
        static let Institution                  = "Institution"
        static let InstitutionId                = "InstitutionId"
        static let SearchString                 = "SearchString"
        static let RuleId                       = "RuleId"
        static let TabIndex                     = "TabIndex"
        static let Account                      = "Account"
        static let AccountId                    = "AccountId"
        static let ProductId                    = "ProductId"
        static let ServerMessageTitle           = "ServerMessageTitle"
        static let ServerMessageContent         = "ServerMessageContent"
        static let ServerMessageOKButton        = "ServerMessageOKButton"
    }
    
    static func userInfoForInstitution(_ institution: Institution) -> [AnyHashable: Any] {
        let userInfo: [AnyHashable: Any] = [Notifications.Keys.Institution: institution,
                                            Notifications.Keys.InstitutionId: institution.institutionId]
        return userInfo
    }
    
    static func userInfoForAccount(_ account: Account) -> [AnyHashable: Any] {
        let userInfo: [AnyHashable: Any] = [Notifications.Keys.Account: account,
                                            Notifications.Keys.AccountId: account.accountId]
        return userInfo
    }
    
    static func userInfoForServerMessage(title: String, content: String, okButton: String) -> [AnyHashable: Any] {
        let userInfo: [AnyHashable: Any] = [Notifications.Keys.ServerMessageTitle: title,
                                            Notifications.Keys.ServerMessageContent: content,
                                            Notifications.Keys.ServerMessageOKButton: okButton]
        return userInfo
    }
}
