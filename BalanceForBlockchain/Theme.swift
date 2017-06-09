//
//  Theme.swift
//  Bal
//
//  Created by Benjamin Baron on 2/4/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

enum ThemeType: Int {
    case auto   = 0
    case light  = 1
    case dark   = 2
}

var CurrentTheme: Theme {
    switch defaults.selectedThemeType {
    case .light:
        return LightTheme()
    case .dark:
        return DarkTheme()
    default:
        return defaults.darkMode ? DarkTheme() : LightTheme()
    }
}

protocol Theme {
    var type: ThemeType { get }
    var defaults: DefaultsTheme { get }
    var balanceTextField: BalanceTextFieldTheme { get }
    var tabs: TabsTheme { get }
    var lock: LockTheme { get }
    var accounts: AccountsTheme { get }
}

struct DefaultsTheme {
    let appearance: NSAppearance
    let backgroundColor: NSColor
    let foregroundColor: NSColor
    let material: NSVisualEffectMaterial
    let size: CGSize
    let touchBarFont: NSFont
    let totalFooter: DefaultsTheme.TotalFooterTheme
    let cell: DefaultsTheme.CellTheme
    
    struct TotalFooterTheme {
        let totalBackgroundColor: NSColor
    }
    
    struct CellTheme {
        let primaryFont: NSFont
        let secondaryFont: NSFont
        
        let backgroundColor: NSColor
        let hoverBackgroundColor: NSColor
        let spacerColor: NSColor
        
        let intercellSpacing: NSSize
    }
}

struct BalanceTextFieldTheme {
    let activeBorderColor: NSColor
    let inactiveBorderColor: NSColor
    let backgroundColor: NSColor
    let textColor: NSColor
    let placeHolderTextColor: NSColor
    let font: NSFont
}

struct TabsTheme {
    let footer: TabsTheme.FooterTheme
    
    struct FooterTheme {
        let backgroundColor: NSColor
        let textColor: NSColor
        let preferencesIcon: NSImage
        let syncButtonColor: NSColor
    }
}

struct LockTheme {
    let titleFont: NSFont
    let explanationFont: NSFont
    let passwordBackgroundColor: NSColor
    let passwordActiveBorderColor: NSColor
    let passwordInactiveBorderColor: NSColor
    let passwordTextColor: NSColor
    let passwordPlaceholderColor: NSColor
}

struct AccountsTheme {
    let headerCell: AccountsTheme.HeaderCellTheme
    let cell: AccountsTheme.CellTheme
    let cellExpansion: AccountsTheme.CellExpansionTheme
    let fixPasswordPrompt: AccountsTheme.FixPasswordPromptTheme
    let prompt: AccountsTheme.PromptTheme
    
    struct HeaderCellTheme {
        let height: CGFloat
        let genericInstitutionBrandColor: NSColor
        let genericInstitutionFont: NSFont
        let genericInstitutionTextColor: NSColor
    }
    
    struct CellTheme {
        let height: CGFloat
        let dimmedAlpha: CGFloat
        let passwordInvalidDimmedAlpha: CGFloat
        
        let nameFont: NSFont
        
        let amountFont: NSFont
        let amountColor: NSColor
        let amountColorCents: NSColor
        let amountColorPositive: NSColor
        
        let availableFont: NSFont
        let availableColor: NSColor
    }
    
    struct CellExpansionTheme {
        let font: NSFont
        let searchButtonBackgroundColor: NSColor
    }
    
    struct FixPasswordPromptTheme {
        let headerFont: NSFont
        let headerTextColor : NSColor
        let buttonTextColor: NSColor
        let nameFont: NSFont
        let nameTextColor: NSColor
        let separatorColor: NSColor
    }
    
    struct PromptTheme {
        let promptFont: NSFont
    }
}
