//
//  ExchangeAPIURLSession.swift
//  BalanceUnitTests
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

typealias MockDataTaskResponse = (data: Data?, response: URLResponse?, error: Error?)
fileprivate typealias MockDataTaskResponseAction = (MockDataTaskResponse) -> Void

class ExchangeAPIURLSession: URLSession {
    
    var dataTask: MockDataTaskResponse?
    
    class var mockURL: URL? {
        return URL(string: "http://www.mocktest.com")
    }
    
    class func httpURLResponse(statusCode: Int) -> URLResponse? {
        guard let mockURL = mockURL else {
            return nil
        }
        
        return HTTPURLResponse(url: mockURL,
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    {
        return ExchangeAPIURLSessionDataTask(dataResponse: dataTask, dataAction: completionHandler)
    }
    
}

fileprivate class ExchangeAPIURLSessionDataTask: URLSessionDataTask {
    
    private var dataResponse: MockDataTaskResponse?
    private var dataAction: MockDataTaskResponseAction

    init(dataResponse: MockDataTaskResponse?, dataAction: @escaping MockDataTaskResponseAction) {
        self.dataResponse = dataResponse
        self.dataAction = dataAction
    }

    override func resume() {
        guard let dataResponse = dataResponse else {
            sendEmptyResponse()
            return
        }
        
        dataAction(dataResponse)
    }
    
    private func sendEmptyResponse() {
        let noReponsePresentedError = NSError(domain: "com.test.bittrex",
                                              code: 1234,
                                              userInfo: nil)
        
        guard let httpURLResponse = ExchangeAPIURLSession.httpURLResponse(statusCode: 404) else {
            return dataAction((nil, nil, noReponsePresentedError))
        }
        
        dataAction((nil, httpURLResponse, noReponsePresentedError))
    }
    
}
