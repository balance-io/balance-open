//
//  Theme.swift
//  BalanceiOS
//
//  Created by Benjamin Baron on 2/2/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit

var CurrentTheme: Theme = {
    return OpenTheme()
}()

protocol Theme {
    var accounts: AccountsTheme { get }
    var transactions: TransactionsTheme { get }
    var priceTicker: PriceTickerTheme { get }
}

struct AccountsTheme {
    let backgroundColor: UIColor
    let header: HeaderTheme
    let card: CardTheme
    let headerCell: HeaderCellTheme
    let cell: CellTheme
    
    struct HeaderTheme {
        let titleLabelFont: UIFont
        let titleLabelColor: UIColor
        let addAccountButtonColor: UIColor
        let refreshControlColor: UIColor
    }
    
    struct CardTheme {
        let cornerRadius: CGFloat
    }
    
    struct HeaderCellTheme {
        let height: CGFloat
        
        let nameFont: UIFont
        let nameColor: UIColor
        let totalBalanceFont: UIFont
        let totalBalanceColor: UIColor
        let bottomBorderColor: UIColor
    }
    
    struct CellTheme {
        let height: CGFloat
        
        let currencyNameFont: UIFont
        let currencyNameColor: UIColor
        let amountFont: UIFont
        let amountColor: UIColor
        let bottomBorderColor: UIColor
        let detailLabelFont: UIFont
        let detailLabelColor: UIColor
    }
}

struct TransactionsTheme {
    let collectionView: CollectionViewTheme
    let cell: CellTheme
    
    struct CollectionViewTheme {
        let backgroundColor: UIColor
        let headerHeight: CGFloat
    }
    
    struct CellTheme {
        let height: CGFloat
        let backgroundColor: UIColor
        let cornerRadius: CGFloat
        let shadowColor: UIColor
        let shadowOffset: CGSize
        let shadowRadius: CGFloat
        let shadowOpacity: Float
        
        let institutionNameFont: UIFont
        let transactionTypeFont: UIFont
        let amountFont: UIFont
        let userCurrencyAmountFont: UIFont
    }
}

struct PriceTickerTheme {
    let collectionView: CollectionViewTheme
    let cell: CellTheme
    
    struct CollectionViewTheme {
        let backgroundColor: UIColor
        let headerReferenceSize: CGSize
        let sectionInset: UIEdgeInsets
        let minimumLineSpacing: CGFloat
    }
    
    struct CellTheme {
        let height: CGFloat
        let backgroundColor: UIColor
        let cornerRadius: CGFloat
        let shadowColor: UIColor
        let shadowOffset: CGSize
        let shadowRadius: CGFloat
        let shadowOpacity: Float
        
        let currencyNameFont: UIFont
        let amountFont: UIFont
    }
}
