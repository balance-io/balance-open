//
//  OpenTheme.swift
//  BalanceiOS
//
//  Created by Benjamin Baron on 2/2/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit

struct OpenTheme: Theme {
    var accounts: AccountsTheme {
        let backgroundColor = UIColor.black
        
        let header = AccountsTheme.HeaderTheme(
            titleLabelFont: .boldSystemFont(ofSize: 25),
            titleLabelColor: .white,
            addAccountButtonColor: .white,
            refreshControlColor: .white
        )
        
        let card = AccountsTheme.CardTheme(
            cornerRadius: 20.0
        )
        
        let headerCell = AccountsTheme.HeaderCellTheme(
            height: 60.0,
            nameFont: UIFont.Balance.monoFont(ofSize: 16.0, weight: .semibold),
            nameColor: .white,
            totalBalanceFont: UIFont.Balance.monoFont(ofSize: 16.0, weight: .semibold),
            totalBalanceColor: .white,
            bottomBorderColor: UIColor(white: 1.0, alpha: 0.06)
        )
                
        let cell = AccountsTheme.CellTheme(
            height: 60.0,
            currencyNameFont: UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular),
            currencyNameColor: UIColor(white: 1.0, alpha: 0.8),
            amountFont: UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular),
            amountColor:  UIColor(white: 1.0, alpha: 0.95),
            bottomBorderColor: UIColor(white: 1.0, alpha: 0.06),
            detailLabelFont: UIFont.Balance.monoFont(ofSize: 14.0, weight: .medium),
            detailLabelColor: .white
        )
        
        let balanceBar = AccountsTheme.BalanceBarTheme(
            height: 60.0,
            backgroundColor: UIColor(red: 39.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 0.6),
            titleFont: UIFont.Balance.font(ofSize: 16.0, weight: .semibold),
            titleColor: .white,
            totalBalanceFont: UIFont.Balance.monoFont(ofSize: 16.0, weight: .bold),
            totalBalanceColor: .white
        )
        
        return AccountsTheme(backgroundColor: backgroundColor, header: header, card: card, headerCell: headerCell, cell: cell, balanceBar: balanceBar)
    }
    
    var transactions: TransactionsTheme {
        let collectionView = TransactionsTheme.CollectionViewTheme(
            backgroundColor: UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1.0),
            headerHeight: 45
        )
        
        let cell = TransactionsTheme.CellTheme(
            height: 60.0,
            backgroundColor: .white,
            cornerRadius: 20.0,
            shadowColor: .black,
            shadowOffset: .zero,
            shadowRadius: 2.0,
            shadowOpacity: 0.04,
            
            institutionNameFont: UIFont.Balance.monoFont(ofSize: 12.0, weight: .medium),
            transactionTypeFont: UIFont.Balance.font(ofSize: 12.0, weight: .medium),
            amountFont: UIFont.Balance.monoFont(ofSize: 14.0, weight: .medium),
            userCurrencyAmountFont: UIFont.Balance.monoFont(ofSize: 14.0, weight: .medium))
        
        return TransactionsTheme(collectionView: collectionView, cell: cell)
    }
    
    var priceTicker: PriceTickerTheme {
        let collectionView = PriceTickerTheme.CollectionViewTheme(
            backgroundColor: UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1.0),
            headerReferenceSize: CGSize(width: 30, height: 30),
            sectionInset: UIEdgeInsetsMake(10, 0, 10, 0),
            minimumLineSpacing: 10.0
        )
        
        let cell = PriceTickerTheme.CellTheme(
            height: 50.0,
            backgroundColor: .white,
            cornerRadius: 20.0,
            shadowColor: .black,
            shadowOffset: .zero,
            shadowRadius: 2.0,
            shadowOpacity: 0.04,
            
            currencyNameFont: UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular),
            amountFont: UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular)
        )
        
        return PriceTickerTheme(collectionView: collectionView, cell: cell)
    }
}
