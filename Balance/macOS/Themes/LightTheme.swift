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
        let appearance = NSAppearance(named: NSAppearance.Name.vibrantLight) ?? NSAppearance.current!
        let backgroundColor = NSColor(deviceRedInt: 232, green: 234, blue: 237)
        let foregroundColor = NSColor(deviceRedInt: 19, green: 22, blue: 25)
        let material = NSVisualEffectView.Material.light
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
        
        let searchField = DefaultsTheme.SearchFieldTheme(
            backgroundColor: NSColor(deviceRedInt: 255, green: 255, blue: 255),
            borderColor: NSColor(deviceRedInt: 180, green: 184, blue: 189),
            placeHolderStringColor: NSColor(deviceRedInt: 54, green: 65, blue: 77, alpha: 0.8),
            font: NSFont.systemFont(ofSize: 13.5),
            textColor: NSColor(deviceRedInt: 54, green: 65, blue: 77),
            searchIconImage: NSImage(named: NSImage.Name(rawValue: "search-icon-light"))!
        )
        
        return DefaultsTheme(appearance: appearance, backgroundColor: backgroundColor, foregroundColor: foregroundColor, material: material, size: size, touchBarFont: touchBarFont, totalFooter: totalFooter, cell: cell, searchField: searchField)
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
    
    var tabs: TabsTheme {
        let header = TabsTheme.HeaderTheme(
            backgroundColor: NSColor(deviceRedInt: 230, green: 231, blue: 235),
            topColor: NSColor(deviceRedInt: 242, green: 244, blue: 245),
            bottomColor: NSColor(deviceRedInt: 235, green: 237, blue: 240),
            tabFont: NSFont.systemFont(ofSize: 10.5),
            tabFontColor: NSColor(deviceRedInt: 113, green: 125, blue: 138),
            tabFontColorActive: NSColor(deviceRedInt: 19, green: 22, blue: 25),
            tabIconBorderColor: NSColor.black,
            tabIconColorActive: NSColor(deviceRedInt: 19, green: 22, blue: 25),
            tabIconColorInactive: NSColor(deviceRedInt: 113, green: 125, blue: 138),
            tabIconNotificationBubbleColor: NSColor(deviceRedInt: 0, green: 157, blue: 255)
        )
        
        let footer = TabsTheme.FooterTheme(
            backgroundColor: NSColor(deviceRedInt: 255, green: 255, blue: 255),
            textColor: NSColor(deviceRedInt: 107, green: 120, blue: 132),
            preferencesIcon: NSImage(named: NSImage.Name(rawValue: "gear-icon-light"))!,
            syncButtonColor: NSColor(deviceRedInt: 107, green: 120, blue: 132)
        )
        
        return TabsTheme(header: header, footer: footer)
    }
    
    var addAccounts: AddAccountsTheme {
        let institutionNameFont = NSFont.systemFont(ofSize: 23)
        
        let welcomeFont = NSFont.lightSystemFont(ofSize: 21)
        
        let labelFont = NSFont.systemFont(ofSize: 12)
        let textColor = NSColor.white
        
        let statusFont = NSFont.systemFont(ofSize: 14)
        let statusColor = NSColor(deviceWhiteInt: 10, alpha: 0.6)
        
        let buttonFont = NSFont.systemFont(ofSize: 14)
        let buttonBackgroundColor = NSColor(deviceWhiteInt: 255, alpha: 0.15)
        let buttonBorderColor = NSColor(deviceWhiteInt: 255, alpha: 0.7)
        
        let lineColor = NSColor(deviceWhiteInt: 255, alpha: 0.15)
        
        let onePasswordButtonImage = NSImage(named: NSImage.Name(rawValue: "onepassword-button-light"))!
        let waveImage = NSImage(named: NSImage.Name(rawValue: "waves-light"))!
        let padlockImage = NSImage(named: NSImage.Name(rawValue: "padlockInRoundedRectangle-light"))!
        
        let searchHeaderBackgroundColor = NSColor(deviceRedInt: 167, green: 175, blue: 185)
        let searchHeaderFont = NSFont.mediumSystemFont(ofSize: 13)
        let searchHeaderPopularFont = NSFont.semiboldSystemFont(ofSize: 13)
        let searchHeaderColor = NSColor(deviceWhiteInt: 255)
        let searchPopularFont = NSFont.mediumSystemFont(ofSize: 14)
        let searchPopularColor = NSColor(deviceRedInt: 18, green: 22, blue: 25)
        let searchMoreResultsFont = NSFont.systemFont(ofSize: 13)
        let searchMoreResultsColor = NSColor(deviceRedInt: 18, green: 22, blue: 25, alpha: 0.72)
        
        let signUpFieldActiveBorderColor = NSColor(deviceRedInt: 203, green: 226, blue: 255, alpha: 0.5)
        let signUpFieldInactiveBorderColor = NSColor.clear
        let signUpFieldBackgroundColor = NSColor(deviceWhiteInt: 255, alpha: 0.16)
        let signUpFieldTextColor = NSColor.white
        let signUpFieldplaceHolderTextColor = NSColor(deviceRedInt: 235, green: 240, blue: 245, alpha: 0.8)
        let signUpFieldFont = NSFont.systemFont(ofSize: 13.5)
        
        let emailIssueInfoLabelNameFont = NSFont.boldSystemFont(ofSize: 12)
        let emailIssueInfoLabelNameColor = NSColor.black
        let emailIssueInfoLabelValueFont = NSFont.systemFont(ofSize: 12)
        let emailIssueInfoLabelValueColor = NSColor.darkGray
        let emailIssueMessageLabelFont = NSFont.systemFont(ofSize: 12)
        
        return AddAccountsTheme(institutionNameFont: institutionNameFont,  welcomeFont: welcomeFont, labelFont: labelFont, textColor: textColor, statusFont: statusFont, statusColor: statusColor, buttonFont: buttonFont, buttonBackgroundColor: buttonBackgroundColor, buttonBorderColor: buttonBorderColor, lineColor: lineColor, onePasswordButtonImage: onePasswordButtonImage, waveImage: waveImage, padlockImage: padlockImage, searchHeaderBackgroundColor: searchHeaderBackgroundColor, searchHeaderFont: searchHeaderFont, searchHeaderPopularFont: searchHeaderPopularFont, searchHeaderColor: searchHeaderColor, searchPopularFont: searchPopularFont, searchPopularColor: searchPopularColor, searchMoreResultsFont: searchMoreResultsFont, searchMoreResultsColor: searchMoreResultsColor, signUpFieldActiveBorderColor: signUpFieldActiveBorderColor, signUpFieldInactiveBorderColor: signUpFieldInactiveBorderColor, signUpFieldBackgroundColor: signUpFieldBackgroundColor, signUpFieldTextColor: signUpFieldTextColor, signUpFieldplaceHolderTextColor: signUpFieldplaceHolderTextColor, signUpFieldFont: signUpFieldFont, emailIssueInfoLabelNameFont: emailIssueInfoLabelNameFont, emailIssueInfoLabelNameColor: emailIssueInfoLabelNameColor, emailIssueInfoLabelValueFont: emailIssueInfoLabelValueFont, emailIssueInfoLabelValueColor: emailIssueInfoLabelValueColor, emailIssueMessageLabelFont: emailIssueMessageLabelFont)
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
            
            altAmountFont: NSFont.monospacedDigitSystemFont(ofSize: 12),
            altAmountColor: NSColor(deviceRedInt: 19, green: 22, blue: 25, alpha: 0.64),
            
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
    
    var transactions: TransactionsTheme {
        let headerCell = TransactionsTheme.HeaderCellTheme(
            height: 20.0,
            backgroundColor: NSColor(deviceRedInt: 177, green: 184, blue: 193),
            pendingBackgroundColor: NSColor(deviceRedInt: 240, green: 110, blue: 62),
            dateFont: NSFont.semiboldSystemFont(ofSize: 9),
            dateColor: NSColor(deviceWhiteInt: 255),
            pendingDateColor: NSColor(deviceWhiteInt: 255)
        )
        
        let cell = TransactionsTheme.CellTheme(
            height: 45.0,
            dimmedAlpha: 1.0,
            
            nameFont: NSFont.systemFont(ofSize: 13.5),
            
            addressFont: NSFont.systemFont(ofSize: 11),
            addressColor: NSColor(deviceRedInt: 19, green: 22, blue: 25, alpha: 0.6),
            
            
            amountFont: NSFont.monospacedDigitSystemFont(ofSize: 14),
            amountColor: defaults.foregroundColor,
            amountColorCents: NSColor(deviceRedInt: 19, green: 22, blue: 25, alpha: 0.64),
            amountColorPositive: NSColor(deviceRedInt: 33, green: 143, blue: 0),
            
            institutionCircleBackground: NSColor(deviceRedInt: 255, green: 255, blue: 255),
            institutionInitialsFont: NSFont.mediumSystemFont(ofSize: 9),
            institutionInitialsColor: NSColor(deviceRedInt: 113, green: 125, blue: 138)
        )
        
        let cellExpansion = TransactionsTheme.CellExpansionTheme(
            institutionFont: NSFont.semiboldSystemFont(ofSize: 13),
            accountFont: NSFont.systemFont(ofSize: 12),
            fontColor: NSColor(deviceWhiteInt: 255),
            institutionBackground: NSColor(deviceWhiteInt: 0, alpha: 0.05)
        )
        
        return TransactionsTheme(headerCell: headerCell, cell: cell, cellExpansion: cellExpansion)
    }
    
    var feed: FeedTheme {
        let emptyState = FeedTheme.EmptyState(
            icon: NSImage(named: NSImage.Name(rawValue: "feed-empty-state-icon-light"))!,
            titleFont: NSFont.systemFont(ofSize: 22),
            bodyFont: NSFont.systemFont(ofSize: 13)
        )
        
        let defaultRulesPrompt = FeedTheme.DefaultRulesPromptTheme(
            headerFont: NSFont.mediumSystemFont(ofSize: 13),
            headerTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            
            buttonTextColor: NSColor(deviceRedInt: 103, green: 110, blue: 117, alpha: 1),
            
            nameFont: NSFont.systemFont(ofSize: 13),
            nameBoldFont: NSFont.boldSystemFont(ofSize: 13),
            nameTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            
            categoryBackgroundColor: NSColor(deviceRedInt: 132, green: 61, blue: 147),
            
            separatorColor: NSColor(deviceWhiteInt: 255, alpha: 0.05)
        )
        
        let notificationsBar = FeedTheme.NotificationsBar(
            noUnreadColor1: NSColor(deviceRedInt: 81, green: 93, blue: 107, alpha: 0.9),
            noUnreadColor2: NSColor(deviceRedInt: 81, green: 93, blue: 107),
            
            unreadColor1: NSColor(deviceRedInt: 0, green: 121, blue: 247, alpha: 0.9),
            unreadColor2: NSColor(deviceRedInt: 0, green: 121, blue: 247),
            
            font: NSFont.mediumSystemFont(ofSize: 12),
            fontColor: NSColor(deviceWhiteInt: 255)
        )
        
        let headerCell = FeedTheme.HeaderCellTheme(
            height: transactions.headerCell.height,
            backgroundColor: transactions.headerCell.backgroundColor,
            dateFont: transactions.headerCell.dateFont,
            dateColor: transactions.headerCell.dateColor
        )
        
        let cell = FeedTheme.CellTheme(
            height: 52,
            dimmedAlpha: transactions.cell.dimmedAlpha,
        
            nameFont: defaults.cell.primaryFont,
            nameColor: NSColor(deviceWhiteInt: 65),
            
            nameBoldFont: NSFont.mediumSystemFont(ofSize: defaults.cell.primaryFont.pointSize),
            nameBoldColor: NSColor(deviceWhiteInt: 10),
            
            ruleFont: defaults.cell.primaryFont,
            ruleColor: defaults.foregroundColor,
            
            unreadIndicatorColor: NSColor(deviceRedInt: 0, green: 121, blue: 247)
        )
        
        let cellExpansion = FeedTheme.CellExpansionTheme(
            institutionFont: NSFont.semiboldSystemFont(ofSize: 13),
            accountFont: NSFont.systemFont(ofSize: 12),
            fontColor: NSColor(deviceWhiteInt: 255),
            institutionBackground: NSColor(deviceWhiteInt: 0, alpha: 0.05)
        )
        
        return FeedTheme(emptyState: emptyState, defaultRulesPrompt: defaultRulesPrompt, notificationsBar: notificationsBar, headerCell: headerCell, cell: cell, cellExpansion: cellExpansion)
    }
}
