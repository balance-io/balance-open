//
//  MockURLSession.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 04/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal class MockSession: URLSession
{
    // Static
    override static var shared: URLSession {
        return MockSession()
    }
    
    // Internal
    internal var mockResponse: Response?
    
    // MARK: URLSession
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    {
        guard let unwrappedMockResponse = self.mockResponse else
        {
            return super.dataTask(with: request, completionHandler: completionHandler)
        }
        
        return Task(request: request, response: unwrappedMockResponse, completionHandler: completionHandler)
    }
}

// MARK: Response

internal extension MockSession
{
    internal struct Response
    {
        internal let data: Data?
        internal let statusCode: Int
        internal let headers: [String : String]?
    }
}

// MARK: Task

internal extension MockSession
{
    internal class Task: URLSessionDataTask
    {
        // Private
        private let request: URLRequest
        private let mockedResponse: Response
        private let completionHandler: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
        
        // MARK: Initialization
        
        internal init(request: URLRequest, response: Response, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)
        {
            self.request = request
            self.mockedResponse = response
            self.completionHandler = completionHandler
        }
        
        // MARK: URLSessionDataTask
        
        override func resume()
        {
            guard let url = self.request.url else
            {
                return
            }
            
            let urlResponse = HTTPURLResponse(url: url, statusCode: self.mockedResponse.statusCode, httpVersion: nil, headerFields: self.mockedResponse.headers)
            self.completionHandler(self.mockedResponse.data, urlResponse, nil)
        }
    }
}
