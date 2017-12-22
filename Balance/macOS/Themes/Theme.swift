//
//  Theme.swift
//  Bal
//
//  Created by Benjamin Baron on 2/4/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

var CurrentTheme: Theme {
    return OpenTheme()
}

protocol Theme {
    var type: ThemeType { get }
    var defaults: DefaultsTheme { get }
    var lock: LockTheme { get }
    var tabs: TabsTheme { get }
    var addAccounts: AddAccountsTheme { get }
    var emailIssue: EmailIssueTheme { get }
    var accounts: AccountsTheme { get }
    var transactions: TransactionsTheme { get }
    var priceTicker: PriceTickerTheme { get }
}

struct DefaultsTheme {
    let appearance: NSAppearance
    let backgroundColor: NSColor
    let foregroundColor: NSColor
    let material: NSVisualEffectView.Material
    let size: CGSize
    let touchBarFont: NSFont
    let totalFooter: DefaultsTheme.TotalFooterTheme
    let cell: DefaultsTheme.CellTheme
    let searchField: DefaultsTheme.SearchFieldTheme
    
    struct TotalFooterTheme {
        let totalBackgroundColor: NSColor
        let titleFont: NSFont
        let titleColor: NSColor
        let amountFont: NSFont
        let amountColor: NSColor
    }
    
    struct CellTheme {
        let primaryFont: NSFont
        let secondaryFont: NSFont
        
        let backgroundColor: NSColor
        let spacerColor: NSColor
        
        let intercellSpacing: NSSize
    }
    
    struct SearchFieldTheme {
        let backgroundColor: NSColor
        let borderColor: NSColor
        let placeHolderStringColor: NSColor
        let font: NSFont
        let textColor: NSColor
        let searchIconImage: NSImage
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

struct TabsTheme {
    let header: TabsTheme.HeaderTheme
    
    struct HeaderTheme {
        let tabFont: NSFont
        let addAccountIcon: NSImage
        let preferencesIcon: NSImage
    }
}

struct AddAccountsTheme {
    let institutionNameFont: NSFont
    
    let welcomeFont: NSFont

    let labelFont: NSFont
    let textColor: NSColor
    
    let statusFont: NSFont
    let statusColor: NSColor
    
    let buttonFont: NSFont
    let buttonBackgroundColor: NSColor
    let buttonBorderColor: NSColor
    
    let lineColor: NSColor
    
    let onePasswordButtonImage: NSImage
    let waveImage: NSImage
    let padlockImage: NSImage
    
    let searchHeaderBackgroundColor: NSColor
    let searchHeaderFont: NSFont
    let searchHeaderPopularFont: NSFont
    let searchHeaderColor: NSColor
    let searchPopularFont: NSFont
    let searchPopularColor: NSColor
    let searchMoreResultsFont: NSFont
    let searchMoreResultsColor: NSColor
    
    let signUpFieldActiveBorderColor: NSColor
    let signUpFieldInactiveBorderColor: NSColor
    let signUpFieldBackgroundColor: NSColor
    let signUpFieldTextColor: NSColor
    let signUpFieldplaceHolderTextColor: NSColor
    let signUpFieldFont: NSFont
}

struct EmailIssueTheme {
    let infoLabelNameFont: NSFont
    let infoLabelNameColor: NSColor
    let infoLabelValueFont: NSFont
    let infoLabelValueColor: NSColor
    let messageLabelFont: NSFont
    
    let inputFieldActiveBorderColor: NSColor
    let inputFieldInactiveBorderColor: NSColor
    let inputFieldTextColor: NSColor
    let inputFieldPlaceholderTextColor: NSColor
}

struct AccountsTheme {
    let headerCell: AccountsTheme.HeaderCellTheme
    let cell: AccountsTheme.CellTheme
    let cellExpansion: AccountsTheme.CellExpansionTheme
    let fixPasswordPrompt: AccountsTheme.FixPasswordPromptTheme
    let prompt: AccountsTheme.PromptTheme
    
    struct HeaderCellTheme {
        let height: CGFloat
        let nameFont: NSFont
        let nameColor: NSColor
        let amountFont: NSFont
        let amountColor: NSColor
    }
    
    struct CellTheme {
        let height: CGFloat
        let dimmedAlpha: CGFloat
        let passwordInvalidDimmedAlpha: CGFloat
        
        let nameFont: NSFont
        let nameColor: NSColor

        let amountFont: NSFont
        let amountColor: NSColor
        let amountColorCents: NSColor
        let amountColorPositive: NSColor
        
        let altAmountFont: NSFont
        let altAmountColor: NSColor
        
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

struct TransactionsTheme {
    let noResultsFont: NSFont
    let headerCell: TransactionsTheme.HeaderCellTheme
    let cell: TransactionsTheme.CellTheme
    let cellExpansion: TransactionsTheme.CellExpansionTheme
    
    struct HeaderCellTheme {
        let height: CGFloat
        let dateFont: NSFont
        let dateColor: NSColor
        let dateAlpha: CGFloat
    }
    
    struct CellTheme {
        let height: CGFloat
        let dimmedAlpha: CGFloat
        
        let backgroundViewColor: NSColor
        
        let nameFont: NSFont
        
        let typeFont: NSFont
        let typeColorSent: NSColor
        let typeColorReceived: NSColor
        let typeColorTraded: NSColor

        let amountFont: NSFont
        let amountColor: NSColor
        let amountColorCents: NSColor
        let amountColorPositive: NSColor
        
        let altAmountFont: NSFont
        let altAmountColor: NSColor
    }
    
    struct CellExpansionTheme {
        let institutionFont: NSFont
        let accountFont: NSFont
        let fontColor: NSColor
        let institutionBackground: NSColor
    }
}

struct PriceTickerTheme {
    let headerCell: PriceTickerTheme.HeaderCellTheme
    let cell: PriceTickerTheme.CellTheme
    
    struct HeaderCellTheme {
        let height: CGFloat
        
        let nameFont: NSFont
        let nameColor: NSColor
    }
    
    struct CellTheme {
        let height: CGFloat
        
        let codeFont: NSFont
        let codeColor: NSColor
        
        let nameFont: NSFont
        let nameColor: NSColor
        
        let rateFont: NSFont
        let rateColor: NSColor
    }
}
