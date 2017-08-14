//
//  ShapeShiftTransferOperator.swift
//  BalanceOpen
//
//  Created by Red Davis on 09/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class ShapeShiftTransferOperator: TransferOperator
{
    // Private
    private let apiClient: ShapeShiftAPIClient = {
        let client = ShapeShiftAPIClient()
        // TODO: add the Balance API key
        // client.apiKey = ""
        return client
    }()
    
    private let request: TransferRequest
    private var coinPair: ShapeShiftAPIClient.CoinPair?
    
    // MARK: Initialization
    
    internal init(request: TransferRequest)
    {
        self.request = request
    }
    
    // MARK: Quote
    
    func fetchQuote(_ completionHandler: @escaping (_ quote: TransferQuote?, _ error: Swift.Error?) -> Void)
    {
        guard let unwrappedCoinPair = self.coinPair else
        {
            self.fetchCoinPair({ [unowned self] (success, error) in
                guard success else
                {
                    completionHandler(nil, error)
                    return
                }
                
                self.fetchQuote(completionHandler)
            })
            
            return
        }
        
        // Fetch quote
        self.apiClient.fetchQuote(amount: self.request.amount, pairCode: unwrappedCoinPair.code, completionHandler: { (quote, error) in
            guard let unwrappedQuote = quote else
            {
                completionHandler(nil, error)
                return
            }
            
            let transferQuote = TransferQuote(shapeShiftQuote: unwrappedQuote)
            completionHandler(transferQuote, nil)
        })
    }
    
    // MARK: Transfer
    
    internal func performTransfer(_ completionHandler: @escaping (_ success: Bool, _ error: Swift.Error?) -> Void)
    {
        guard let unwrappedCoinPair = self.coinPair else
        {
            self.fetchCoinPair({ [unowned self] (success, error) in
                guard success else
                {
                    completionHandler(false, error)
                    return
                }
                
                self.performTransfer(completionHandler)
            })
            
            return
        }
        
        // Create transaction request (self.request.sourceAccount - crypto address?)
        // TODO: Return address
        self.apiClient.createTransaction(amount: self.request.amount, recipientAddress: self.request.recipientAddress, pairCode: unwrappedCoinPair.code, returnAddress: nil) { [unowned self] (transactionRequest, error) in
            guard let unwrappedTransactionRequest = transactionRequest else
            {
                completionHandler(false, error)
                return
            }
            
            let withdrawal = Withdrawal(amount: unwrappedTransactionRequest.depositAmount, recipientCryptoAddress: unwrappedTransactionRequest.depositAddress)
            do
            {
                try self.request.sourceAccount.make(withdrawal: withdrawal, completionHandler: completionHandler)
            }
            catch let error
            {
                completionHandler(false, error)
            }
        }
    }
    
    // MARK: Coinpair
    
    private func fetchCoinPair(_ completionHandler: @escaping (_ success: Bool, _ error: Swift.Error?) -> Void)
    {
        self.apiClient.fetchSupportedCoins { [unowned self] (coins, error) in
            guard let unwrappedCoins = coins else
            {
                completionHandler(false, error)
                return
            }
            
            // Find source coin
            guard let sourceCoin = unwrappedCoins.first(where: { (coin) -> Bool in
                return coin.symbol == self.request.sourceCurrency.symbol
            }) else
            {
                completionHandler(false, Error.unsupportedCurrency(currency: self.request.sourceCurrency))
                return
            }
            
            // Find recipient coin
            guard let recipientCoin = unwrappedCoins.first(where: { (coin) -> Bool in
                return coin.symbol == self.request.recipientCurrency.symbol
            }) else
            {
                completionHandler(false, Error.unsupportedCurrency(currency: self.request.recipientCurrency))
                return
            }
            
            // Complete!
            self.coinPair = ShapeShiftAPIClient.CoinPair(input: sourceCoin, output: recipientCoin)
            completionHandler(true, nil)
        }
    }
}


internal extension ShapeShiftTransferOperator
{
    internal enum Error: Swift.Error
    {
        case unsupportedCurrency(currency: Currency)
    }
}
