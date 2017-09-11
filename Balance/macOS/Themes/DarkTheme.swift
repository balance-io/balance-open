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
        let appearance = NSAppearance(named: NSAppearance.Name.vibrantDark) ?? NSAppearance.current!
        let backgroundColor = NSColor(deviceRedInt: 37, green: 42, blue: 48)
        let foregroundColor = NSColor(deviceWhiteInt: 255)
        let material = NSVisualEffectView.Material.dark
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
        
        let searchField = DefaultsTheme.SearchFieldTheme(
            backgroundColor: NSColor(deviceRedInt: 70, green: 81, blue: 92),
            borderColor: NSColor(deviceRedInt: 16, green: 22, blue: 28),
            placeHolderStringColor: NSColor(deviceRedInt: 235, green: 240, blue: 245, alpha: 0.8),
            font: NSFont.systemFont(ofSize: 13.5),
            textColor: NSColor(deviceRedInt: 235, green: 240, blue: 245),
            searchIconImage: NSImage(named: NSImage.Name(rawValue: "search-icon-dark"))!
        )
    
        return DefaultsTheme(appearance: appearance, backgroundColor: backgroundColor, foregroundColor: foregroundColor, material: material, size: size, touchBarFont: touchBarFont, totalFooter: totalFooter, cell: cell, searchField: searchField)
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
    
    var tabs: TabsTheme {
        let header = TabsTheme.HeaderTheme(
            backgroundColor: NSColor(deviceRedInt: 46, green: 56, blue: 66),
            topColor: NSColor(deviceRedInt: 39, green: 46, blue: 53),
            bottomColor: NSColor(deviceRedInt: 37, green: 42, blue: 48),
            tabFont: NSFont.systemFont(ofSize: 10.5),
            tabFontColor: NSColor(deviceRedInt: 132, green: 159, blue: 178),
            tabFontColorActive: NSColor(deviceRedInt: 25, green: 167, blue: 255),
            tabIconBorderColor: NSColor.white,
            tabIconColorActive: NSColor(deviceRedInt: 36, green: 171, blue: 255),
            tabIconColorInactive: NSColor(deviceRedInt: 132, green: 159, blue: 178),
            tabIconNotificationBubbleColor: NSColor(deviceRedInt: 36, green: 171, blue: 255)
        )
    
        let footer = TabsTheme.FooterTheme(
            backgroundColor: NSColor(deviceRedInt: 46, green: 56, blue: 66),
            textColor: NSColor(deviceRedInt: 151, green: 182, blue: 204),
            preferencesIcon: NSImage(named: NSImage.Name(rawValue: "gear-icon-dark"))!,
            syncButtonColor: NSColor(deviceRedInt: 151, green: 182, blue: 204)
        )
        
        return TabsTheme(header: header, footer: footer)
    }
    
    var addAccounts: AddAccountsTheme {
        let institutionNameFont = NSFont.systemFont(ofSize: 23)
        
        let welcomeFont = NSFont.lightSystemFont(ofSize: 21)

        let labelFont = NSFont.systemFont(ofSize: 13)
        let textColor = NSColor.white
        
        let statusFont = NSFont.systemFont(ofSize: 14)
        let statusColor = NSColor(deviceWhiteInt: 255, alpha: 0.7)
    
        let buttonFont = NSFont.systemFont(ofSize: 14)
        let buttonBackgroundColor = NSColor(deviceWhiteInt: 255, alpha: 0.15)
        let buttonBorderColor = NSColor(deviceWhiteInt: 255, alpha: 0.7)
        
        let lineColor = NSColor(deviceWhiteInt: 255, alpha: 0.1)
        
        let onePasswordButtonImage = NSImage(named: NSImage.Name(rawValue: "onepassword-button-light"))!
        let waveImage = NSImage(named: NSImage.Name(rawValue: "waves-light"))!
        let padlockImage = NSImage(named: NSImage.Name(rawValue: "padlockInRoundedRectangle-light"))!
                
        let searchHeaderBackgroundColor = NSColor(deviceRedInt: 53, green: 61, blue: 71)
        let searchHeaderFont = NSFont.mediumSystemFont(ofSize: 13)
        let searchHeaderPopularFont = NSFont.semiboldSystemFont(ofSize: 13)
        let searchHeaderColor = NSColor(deviceRedInt: 234, green: 241, blue: 245)
        let searchPopularFont = NSFont.mediumSystemFont(ofSize: 14)
        let searchPopularColor = NSColor(deviceWhiteInt: 255)
        let searchMoreResultsFont = NSFont.systemFont(ofSize: 13)
        let searchMoreResultsColor = NSColor(deviceWhiteInt: 255, alpha: 0.72)
        
        let signUpFieldActiveBorderColor = NSColor(deviceRedInt: 203, green: 226, blue: 255, alpha: 0.5)
        let signUpFieldInactiveBorderColor = NSColor.clear
        let signUpFieldBackgroundColor = NSColor(deviceWhiteInt: 255, alpha: 0.16)
        let signUpFieldTextColor = NSColor.white
        let signUpFieldplaceHolderTextColor = NSColor(deviceRedInt: 235, green: 240, blue: 245, alpha: 0.8)
        let signUpFieldFont = NSFont.systemFont(ofSize: 13.5)
        
        let emailIssueInfoLabelNameFont = NSFont.boldSystemFont(ofSize: 12)
        let emailIssueInfoLabelNameColor = NSColor.white
        let emailIssueInfoLabelValueFont = NSFont.systemFont(ofSize: 12)
        let emailIssueInfoLabelValueColor = NSColor.lightGray
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
            amountColor: NSColor(deviceWhiteInt: 255, alpha: 0.9),
            amountColorCents: NSColor(deviceRedInt: 153, green: 165, blue: 174),
            amountColorPositive: NSColor(deviceRedInt: 88, green: 184, blue: 33),
            
            altAmountFont: NSFont.monospacedDigitSystemFont(ofSize: 12),
            altAmountColor: NSColor(deviceRedInt: 153, green: 165, blue: 174),
            
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
    
    var transactions: TransactionsTheme {
        let headerCell = TransactionsTheme.HeaderCellTheme(
            height: 20.0,
            backgroundColor: NSColor(deviceRedInt: 46, green: 56, blue: 66),
            pendingBackgroundColor: NSColor(deviceRedInt: 219, green: 87, blue: 29),
            dateFont: NSFont.semiboldSystemFont(ofSize: 9),
            dateColor: NSColor(deviceRedInt: 171, green: 192, blue: 209),
            pendingDateColor: NSColor(deviceWhiteInt: 255)
        )
        
        let cell = TransactionsTheme.CellTheme(
            height: 44.0,
            dimmedAlpha: 1.0,
            
            nameFont: NSFont.systemFont(ofSize: 13.5),
            
            addressFont: NSFont.systemFont(ofSize: 11),
            addressColor: NSColor(deviceRedInt: 153, green: 165, blue: 174),
            
            amountFont: NSFont.monospacedDigitSystemFont(ofSize: 14),
            amountColor: NSColor(deviceWhiteInt: 255, alpha: 0.9),
            amountColorCents: NSColor(deviceRedInt: 153, green: 165, blue: 174),
            amountColorPositive: NSColor(deviceRedInt: 88, green: 184, blue: 33),
            
            institutionCircleBackground: NSColor(deviceRedInt: 50, green: 61, blue: 71),
            institutionInitialsFont: NSFont.mediumSystemFont(ofSize: 9),
            institutionInitialsColor: NSColor(deviceRedInt: 172, green: 192, blue: 209)
        )
        
        let cellExpansion = TransactionsTheme.CellExpansionTheme(
            institutionFont: NSFont.semiboldSystemFont(ofSize: 13),
            accountFont: NSFont.systemFont(ofSize: 12),
            fontColor: NSColor(deviceWhiteInt: 255),
            institutionBackground: NSColor(deviceWhiteInt: 255, alpha: 0.05)
        )
        
        return TransactionsTheme(headerCell: headerCell, cell: cell, cellExpansion: cellExpansion)
    }

    var feed: FeedTheme {
        let emptyState = FeedTheme.EmptyState(
            icon: NSImage(named: NSImage.Name(rawValue: "feed-empty-state-icon-dark"))!,
            titleFont: NSFont.systemFont(ofSize: 22),
            bodyFont: NSFont.systemFont(ofSize: 13)
        )
        
        let defaultRulesPrompt = FeedTheme.DefaultRulesPromptTheme(
            headerFont: NSFont.mediumSystemFont(ofSize: 13),
            headerTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            
            buttonTextColor: NSColor(deviceRed: 0.333, green: 0.353, blue: 0.38, alpha: 1.0),
            
            nameFont: NSFont.systemFont(ofSize: 13),
            nameBoldFont: NSFont.boldSystemFont(ofSize: 13),
            nameTextColor: NSColor(deviceWhiteInt: 255, alpha: 1),
            
            categoryBackgroundColor: NSColor(deviceRedInt: 132, green: 61, blue: 147),
            
            separatorColor: NSColor(deviceWhiteInt: 255, alpha: 0.04)
        )
        
        let notificationsBar = FeedTheme.NotificationsBar(
            noUnreadColor1: NSColor(deviceRedInt: 81, green: 93, blue: 107, alpha: 1),
            noUnreadColor2: NSColor(deviceRedInt: 81, green: 93, blue: 107, alpha: 0.9),
            
            unreadColor1: NSColor(deviceRedInt: 66, green: 158, blue: 255),
            unreadColor2: NSColor(deviceRedInt: 66, green: 158, blue: 255, alpha: 0.9),
            
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
            nameColor: NSColor(deviceWhiteInt: 200),
            
            nameBoldFont: NSFont.mediumSystemFont(ofSize: defaults.cell.primaryFont.pointSize),
            nameBoldColor: NSColor(deviceWhiteInt: 255),
            
            ruleFont: defaults.cell.primaryFont,
            ruleColor: defaults.foregroundColor,
            
            unreadIndicatorColor: NSColor(deviceRedInt: 65, green: 155, blue: 249)
        )
        
        let cellExpansion = FeedTheme.CellExpansionTheme(
            institutionFont: NSFont.semiboldSystemFont(ofSize: 13),
            accountFont: NSFont.systemFont(ofSize: 12),
            fontColor: NSColor(deviceWhiteInt: 255),
            institutionBackground: NSColor(deviceWhiteInt: 255, alpha: 0.05)
        )
        
        return FeedTheme(emptyState: emptyState, defaultRulesPrompt: defaultRulesPrompt, notificationsBar: notificationsBar, headerCell: headerCell, cell: cell, cellExpansion: cellExpansion)
    }
}
