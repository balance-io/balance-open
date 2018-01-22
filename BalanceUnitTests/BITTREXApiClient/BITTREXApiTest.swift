//
//  BITTREXApiTest.swift
//  BalanceUnitTests
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import BalancemacOS

class BITTREXApiTest: XCTestCase {
    
    private let mockInstitutionRepository = MockInstitutionRepository()
    
    func testShouldGetBalances() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: balancesMockURLSession, institutionRepository: mockInstitutionRepository)
            .performAction(for: .getBalances,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let balances = result.object as? [BITTREXBalance],
                                let balance = balances.first else {
                                    XCTFail("Invalid balance Response")
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
        
        BITTREXApi(urlSession: currenciesMockURLSession, institutionRepository: mockInstitutionRepository)
            .performAction(for: .getCurrencies,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let currencies = result.object as? [BITTREXCurrency],
                                let currency = currencies.first else {
                                    XCTFail("Invalid balance Response")
                                    return
                            }
                            
                            XCTAssertTrue(currency.currency == "BTC", "Invalid currency")
                            
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
                                XCTFail("ApiKey should be invalid")
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
    
    var messageErrorMockURLSession: URLSession {
        let currenciesData = BITTREXDataHelper.loadInvalidApiKey()
        return createMockURLSession(with: currenciesData)
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
