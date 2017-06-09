//
//  DarkTheme.swift
//  Bal
//
//  Created by Benjamin Baron on 2/4/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

struct DarkTheme: Theme {
    
    var type: ThemeType = .dark
    
    var defaults: DefaultsTheme {
        let appearance = NSAppearance(named: NSAppearanceNameVibrantDark) ?? NSAppearance.current()
        let backgroundColor = NSColor(deviceRedInt: 37, green: 42, blue: 48)
        let foregroundColor = NSColor(deviceWhiteInt: 255)
        let material = NSVisualEffectMaterial.dark
        let size = CGSize(width: 400, height: 600)
        let touchBarFont = NSFont.systemFont(ofSize: 15)
        
        let totalFooter = DefaultsTheme.TotalFooterTheme(
            totalBackgroundColor: NSColor(deviceRedInt: 46, green: 56, blue: 66, alpha: 0.4)
        )
    
        let cell = DefaultsTheme.CellTheme(
            primaryFont: NSFont.systemFont(ofSize: 13),
            secondaryFont: NSFont.systemFont(ofSize: 11),
            
            backgroundColor: NSColor(deviceRedInt: 30, green: 35, blue: 41),
            hoverBackgroundColor: NSColor(deviceRedInt: 36, green: 43, blue: 51),
            spacerColor: backgroundColor,
            
            intercellSpacing: NSSize(width: 0.5, height: 0.5)
        )
    
        return DefaultsTheme(appearance: appearance, backgroundColor: backgroundColor, foregroundColor: foregroundColor, material: material, size: size, touchBarFont: touchBarFont, totalFooter: totalFooter, cell: cell)
    }
    
    var balanceTextField: BalanceTextFieldTheme {
        let activeBorderColor = NSColor(deviceRedInt: 203, green: 226, blue: 255, alpha: 0.5)
        let inactiveBorderColor = NSColor.clear
        let backgroundColor = NSColor(deviceWhiteInt: 255, alpha: 0.16)
        let textColor = NSColor.white
        let placeHolderTextColor = NSColor(deviceRedInt: 235, green: 240, blue: 245, alpha: 0.8)
        let font = NSFont.systemFont(ofSize: 13.5)
        
        return BalanceTextFieldTheme(activeBorderColor: activeBorderColor, inactiveBorderColor: inactiveBorderColor, backgroundColor: backgroundColor, textColor: textColor, placeHolderTextColor: placeHolderTextColor, font: font)
    }
    
    var tabs: TabsTheme {
        let footer = TabsTheme.FooterTheme(
            backgroundColor: NSColor(deviceRedInt: 46, green: 56, blue: 66),
            textColor: NSColor(deviceRedInt: 151, green: 182, blue: 204),
            preferencesIcon: NSImage(named: "gear-icon-dark")!,
            syncButtonColor: NSColor(deviceRedInt: 151, green: 182, blue: 204)
        )
        
        return TabsTheme(footer: footer)
    }
    
    var lock: LockTheme {
        let titleFont = NSFont.systemFont(ofSize: 22)
        let explanationFont = NSFont.systemFont(ofSize: 13)
        
        let passwordBackgroundColor = NSColor(deviceWhiteInt: 255, alpha: 0.08)
        let passwordActiveBorderColor = NSColor(deviceRedInt: 128, green: 185, blue: 255, alpha: 0.6)
        let passwordInactiveBorderColor = NSColor.clear
        let passwordTextColor = NSColor.white
        let passwordPlaceholderColor = NSColor(deviceWhiteInt: 255, alpha: 0.62)
        
        return LockTheme(titleFont: titleFont, explanationFont: explanationFont, passwordBackgroundColor: passwordBackgroundColor, passwordActiveBorderColor: passwordActiveBorderColor, passwordInactiveBorderColor: passwordInactiveBorderColor, passwordTextColor: passwordTextColor, passwordPlaceholderColor: passwordPlaceholderColor)
    }
    
    var accounts: AccountsTheme {
        let headerCell = AccountsTheme.HeaderCellTheme(
            height: 26.0,
            genericInstitutionBrandColor: NSColor(deviceWhiteInt: 0),
            genericInstitutionFont: NSFont.mediumSystemFont(ofSize: 11),
            genericInstitutionTextColor: NSColor(deviceWhiteInt: 255)
        )
        
        let cell = AccountsTheme.CellTheme(
            height: 57.0,
            dimmedAlpha: 0.65,
            passwordInvalidDimmedAlpha: 0.50,
            
            nameFont: NSFont.systemFont(ofSize: 14),
            
            amountFont: NSFont.monospacedDigitSystemFont(ofSize: 14),
            amountColor: NSColor(deviceWhiteInt: 255, alpha: 0.9),
            amountColorCents: NSColor(deviceRedInt: 153, green: 165, blue: 174),
            amountColorPositive: NSColor(deviceRedInt: 88, green: 184, blue: 33),
            
            availableFont: NSFont.systemFont(ofSize: 10.5),
            availableColor: NSColor(deviceRedInt: 148, green: 158, blue: 168)
        )
        
        let fixPasswordPrompt = AccountsTheme.FixPasswordPromptTheme(
            headerFont: NSFont.mediumSystemFont(ofSize: 13),
            headerTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            buttonTextColor: NSColor(deviceRed: 0.333, green: 0.353, blue: 0.38, alpha: 1.0),
            nameFont: NSFont.mediumSystemFont(ofSize: 13),
            nameTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            separatorColor: NSColor(deviceWhiteInt: 255, alpha: 0.04)
        )
        
        let prompt = AccountsTheme.PromptTheme(
            promptFont: NSFont.systemFont(ofSize: 13)
        )
        
        let cellExpansion = AccountsTheme.CellExpansionTheme(
            font: NSFont.systemFont(ofSize: 12),
            searchButtonBackgroundColor: NSColor(deviceWhiteInt: 255, alpha: 0.2)
        )
        
        return AccountsTheme(headerCell: headerCell, cell: cell, cellExpansion: cellExpansion, fixPasswordPrompt: fixPasswordPrompt, prompt: prompt)
    }
}
