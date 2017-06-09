//
//  LightTheme.swift
//  Bal
//
//  Created by Benjamin Baron on 6/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

struct LightTheme: Theme {

    var type: ThemeType = .light
    
    var defaults: DefaultsTheme {
        let appearance = NSAppearance(named: NSAppearanceNameVibrantLight) ?? NSAppearance.current()
        let backgroundColor = NSColor(deviceRedInt: 232, green: 234, blue: 237)
        let foregroundColor = NSColor(deviceRedInt: 19, green: 22, blue: 25)
        let material = NSVisualEffectMaterial.light
        let size = CGSize(width: 400, height: 600)
        let touchBarFont = NSFont.systemFont(ofSize: 15)
        
        let totalFooter = DefaultsTheme.TotalFooterTheme(
            totalBackgroundColor: NSColor(deviceWhiteInt: 255, alpha: 0.9)
        )
        
        let cell = DefaultsTheme.CellTheme(
            primaryFont: NSFont.systemFont(ofSize: 13),
            secondaryFont: NSFont.systemFont(ofSize: 11),
            
            backgroundColor: NSColor(deviceRedInt: 253, green: 253, blue: 253),
            hoverBackgroundColor: NSColor(deviceWhiteInt: 237),
            spacerColor: NSColor(deviceRedInt: 240, green: 243, blue: 246),
            
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
            backgroundColor: NSColor(deviceRedInt: 255, green: 255, blue: 255),
            textColor: NSColor(deviceRedInt: 107, green: 120, blue: 132),
            preferencesIcon: NSImage(named: "gear-icon-light")!,
            syncButtonColor: NSColor(deviceRedInt: 107, green: 120, blue: 132)
        )
        
        return TabsTheme(footer: footer)
    }
    
    var lock: LockTheme {
        let titleFont = NSFont.systemFont(ofSize: 22)
        let explanationFont = NSFont.systemFont(ofSize: 13)
        
        let passwordBackgroundColor = NSColor.white
        let passwordActiveBorderColor = NSColor(deviceRedInt: 29, green: 128, blue: 251, alpha: 0.5)
        let passwordInactiveBorderColor = NSColor.clear
        let passwordTextColor = NSColor(deviceRedInt: 50, green: 56, blue: 61)
        let passwordPlaceholderColor = NSColor(deviceRedInt: 50, green: 56, blue: 61, alpha: 0.46)
        
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
            amountColor: NSColor(deviceWhiteInt: 10, alpha: 1),
            amountColorCents: NSColor(deviceRedInt: 19, green: 22, blue: 25, alpha: 0.64),
            amountColorPositive: NSColor(deviceRedInt: 33, green: 143, blue: 0),
            
            availableFont: NSFont.systemFont(ofSize: 10.5),
            availableColor: NSColor(deviceRedInt: 114, green: 117, blue: 121)
        )
        
        let fixPasswordPrompt = AccountsTheme.FixPasswordPromptTheme(
            headerFont: NSFont.mediumSystemFont(ofSize: 13),
            headerTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            buttonTextColor: NSColor(deviceRedInt: 103, green: 110, blue: 117, alpha: 1),
            nameFont: NSFont.mediumSystemFont(ofSize: 13),
            nameTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            separatorColor: NSColor(deviceWhiteInt: 255, alpha: 0.05)
        )
        
        let prompt = AccountsTheme.PromptTheme(
            promptFont: NSFont.systemFont(ofSize: 13)
        )
        
        let cellExpansion = AccountsTheme.CellExpansionTheme(
            font: NSFont.systemFont(ofSize: 12),
            searchButtonBackgroundColor: NSColor(deviceWhiteInt: 10, alpha: 0.3)
        )
        
        return AccountsTheme(headerCell: headerCell, cell: cell, cellExpansion: cellExpansion, fixPasswordPrompt: fixPasswordPrompt, prompt: prompt)
    }
    
    var emailIssue: EmailIssueTheme {
        let titleFont = NSFont.lightSystemFont(ofSize: 21)
        let buttonFont = NSFont.systemFont(ofSize: 14)
        let infoLabelNameFont = NSFont.boldSystemFont(ofSize: 12)
        let infoLabelNameColor = NSColor.black
        let infoLabelValueFont = NSFont.systemFont(ofSize: 12)
        let infoLabelValueColor = NSColor.darkGray
        let messageLabelFont = NSFont.systemFont(ofSize: 12)
        
        return EmailIssueTheme(titleFont: titleFont, buttonFont: buttonFont, infoLabelNameFont: infoLabelNameFont, infoLabelNameColor: infoLabelNameColor, infoLabelValueFont: infoLabelValueFont, infoLabelValueColor: infoLabelValueColor, messageLabelFont: messageLabelFont)
    }
}
