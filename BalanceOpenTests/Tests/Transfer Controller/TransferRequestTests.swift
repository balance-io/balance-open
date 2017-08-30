//
//  TransferRequestTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 22/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalanceOpen


internal final class TransferRequestTests: XCTestCase
{
    // Private
    private var btcAccount: BTCAccount!
    private var ethAccount: ETHAccount!
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
        
        self.btcAccount = BTCAccount()
        self.ethAccount = ETHAccount()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Request type
    
    internal func testRequestType()
    {
        let exchangeTransferRequest = try! TransferRequest(source: self.btcAccount, recipient: self.ethAccount, amount: 1.0)
        XCTAssertEqual(exchangeTransferRequest.type, TransferRequest.RequestType.exchange)
        
        let directTransferRequest = try! TransferRequest(source: self.btcAccount, recipient: self.btcAccount, amount: 1.0)
        XCTAssertEqual(directTransferRequest.type, TransferRequest.RequestType.direct)
    }
    
    // MARK: Currecy types
    
    internal func testCurrencyTypes()
    {
        let transferRequest = try! TransferRequest(source: self.btcAccount, recipient: self.ethAccount, amount: 1.0)
        XCTAssertEqual(transferRequest.sourceCurrency, self.btcAccount.currencyType)
        XCTAssertEqual(transferRequest.recipientCurrency, self.ethAccount.currencyType)
    }
    
    // MARK: Initialization errors
    
    internal func testDirectTransferUnsupported()
    {
        self.ethAccount._directTransferOperator = nil
        
        do
        {
            _ = try TransferRequest(source: self.ethAccount, recipient: self.ethAccount, amount: 1.0)
        }
        catch let error as TransferRequest.InitializationError where error == .directTransferUnsupported
        {
            XCTAssert(true)
        }
        catch let error
        {
            XCTFail("Threw invalid error: \(error)")
        }
    }
    
    internal func testExchangeTransferUnsupported()
    {
        self.ethAccount._exchangeTransferOperator = nil
        
        do
        {
            _ = try TransferRequest(source: self.ethAccount, recipient: self.btcAccount, amount: 1.0)
        }
        catch let error as TransferRequest.InitializationError where error == .exchangeTransferUnsupported
        {
            XCTAssert(true)
        }
        catch let error
        {
            XCTFail("Threw invalid error: \(error)")
        }
    }
    
    internal func testWithdrawingUnsupported()
    {
        self.ethAccount._canMakeWithdrawal = false
        
        do
        {
            _ = try TransferRequest(source: self.ethAccount, recipient: self.btcAccount, amount: 1.0)
        }
        catch let error as TransferRequest.InitializationError where error == .sourceAccountDoesNotSupportWithdrawing
        {
            XCTAssert(true)
        }
        catch let error
        {
            XCTFail("Threw invalid error: \(error)")
        }
    }
    
    internal func testAccessingCryptoAddressUnsupported()
    {
        self.btcAccount._canRequestCryptoAddress = false
        
        do
        {
            _ = try TransferRequest(source: self.ethAccount, recipient: self.btcAccount, amount: 1.0)
        }
        catch let error as TransferRequest.InitializationError where error == .recipientAccountDoesNotSupportAccessingCryptoAddress
        {
            XCTAssert(true)
        }
        catch let error
        {
            XCTFail("Threw invalid error: \(error)")
        }
    }
}


fileprivate final class BTCAccount: Transferable
{
    fileprivate var currencyType = Currency(rawValue: "BTC")!
    
    fileprivate var _directTransferOperator: TransferOperator.Type? = ShapeShiftTransferOperator.self
    fileprivate var directTransferOperator: TransferOperator.Type? { return _directTransferOperator }
    
    fileprivate var _exchangeTransferOperator: TransferOperator.Type? = ShapeShiftTransferOperator.self
    fileprivate var exchangeTransferOperator: TransferOperator.Type? { return _exchangeTransferOperator }
    
    fileprivate var _canRequestCryptoAddress: Bool = true
    fileprivate var canRequestCryptoAddress: Bool { return _canRequestCryptoAddress }
    fileprivate func fetchAddress(_ completionHandler: @escaping (_ address: String?, _ error: Error?) -> Void) { }
    
    fileprivate var _canMakeWithdrawal: Bool = true
    fileprivate var canMakeWithdrawal: Bool { return _canMakeWithdrawal }
    fileprivate func make(withdrawal: Withdrawal, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) throws { }
}


fileprivate final class ETHAccount: Transferable
{
    fileprivate var currencyType = Currency(rawValue: "ETH")!
    
    fileprivate var _directTransferOperator: TransferOperator.Type? = ShapeShiftTransferOperator.self
    fileprivate var directTransferOperator: TransferOperator.Type? { return _directTransferOperator }
    
    fileprivate var _exchangeTransferOperator: TransferOperator.Type? = ShapeShiftTransferOperator.self
    fileprivate var exchangeTransferOperator: TransferOperator.Type? { return _exchangeTransferOperator }
    
    fileprivate var _canRequestCryptoAddress: Bool = true
    fileprivate var canRequestCryptoAddress: Bool { return _canRequestCryptoAddress }
    fileprivate func fetchAddress(_ completionHandler: @escaping (_ address: String?, _ error: Error?) -> Void) { }
    
    fileprivate var _canMakeWithdrawal: Bool = true
    fileprivate var canMakeWithdrawal: Bool { return _canMakeWithdrawal }
    fileprivate func make(withdrawal: Withdrawal, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) throws { }
}
