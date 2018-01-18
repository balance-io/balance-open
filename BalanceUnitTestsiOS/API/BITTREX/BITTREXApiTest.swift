//
//  BITTREXApiTest.swift
//  BalanceUnitTests
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import Balance

class BITTREXApiTest: XCTestCase {
    
    func testShouldGetBalances() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: balancesMockURLSession)
            .performAction(for: .getBalances,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let balances = result.object as? [BITTREXBalance],
                                let balance = balances.first else {
                                    assertionFailure("Invalid balance Response")
                                    return
                            }
                            
                            XCTAssertTrue(balance.cryptoAddress == "DLxcEt3AatMyr2NTatzjsfHNoB9NT62HiF", "Invalid balance")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetCurrencies() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: currenciesMockURLSession)
            .performAction(for: .getCurrencies,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let currencies = result.object as? [BITTREXCurrency],
                                let currency = currencies.first else {
                                    assertionFailure("Invalid balance Response")
                                    return
                            }
                            
                            XCTAssertTrue(currency.currency == "BTC", "Invalid currency")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetDeposits() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: depositsMockURLSession)
            .performAction(for: .getAllDepositHistory,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let deposits = result.object as? [BITTREXDepositOrWithdrawal],
                                let deposit = deposits.first else {
                                    assertionFailure("Invalid deposits Response")
                                    return
                            }
                            
                            XCTAssertTrue(deposit.paymentUuid == "554ec664-8842-4fe9-b491-06225becbd59", "Invalid payment UUID")
                            XCTAssertTrue(deposit.currency == "BTC", "Invalid currency")
                            XCTAssertTrue(deposit.amount == 0.00156121, "Invalid amount")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetWithdrawals() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: withdrawalsMockURLSession)
            .performAction(for: .getAllWithdrawalHistory,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let withdrawals = result.object as? [BITTREXDepositOrWithdrawal],
                                let withdrawal = withdrawals.first else {
                                    assertionFailure("Invalid withdrawals Response")
                                    return
                            }
                            
                            XCTAssertTrue(withdrawal.paymentUuid == "b52c7a5c-90c6-4c6e-835c-e16df12708b1", "Invalid payment UUID")
                            XCTAssertTrue(withdrawal.currency == "BTC", "Invalid currency")
                            XCTAssertTrue(withdrawal.amount == 17, "Invalid amount")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetAPIInvalidAPIKeyError() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: messageErrorMockURLSession)
            .performAction(for: .getCurrencies,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard case let .message(errorDescription)? = result.error as? BITTREXApiError else {
                                assertionFailure("ApiKey should be invalid")
                                return
                            }
                            
                            XCTAssertTrue(errorDescription == "Invalid aipkey")
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
}

private extension BITTREXApiTest {
    
    var balancesMockURLSession: URLSession {
        let balancesData = BITTREXDataHelper.loadBalances()
        return createMockURLSession(with: balancesData)
    }
    
    var currenciesMockURLSession: URLSession {
        let currenciesData = BITTREXDataHelper.loadCurrencies()
        return createMockURLSession(with: currenciesData)
    }
    
    var depositsMockURLSession: URLSession {
        let depositsData = BITTREXDataHelper.loadDeposits()
        return createMockURLSession(with: depositsData)
    }
    
    var withdrawalsMockURLSession: URLSession {
        let withdrawalsData = BITTREXDataHelper.loadWithdrawals()
        return createMockURLSession(with: withdrawalsData)
    }
    
    var messageErrorMockURLSession: URLSession {
        let invalidKeyData = BITTREXDataHelper.loadInvalidApiKey()
        return createMockURLSession(with: invalidKeyData)
    }
    
    func createMockURLSession(with responseData: Data?, statusCode: Int? = nil) -> URLSession {
        let mockURLSession = ExchangeAPIURLSession()
        let urlResponse = ExchangeAPIURLSession.httpURLResponse(statusCode: statusCode ?? 200)
        let mockResponse = MockDataTaskResponse(data: responseData,
                                                response: urlResponse,
                                                error: nil)
        mockURLSession.dataTask = mockResponse
        
        return mockURLSession
    }
    
}
