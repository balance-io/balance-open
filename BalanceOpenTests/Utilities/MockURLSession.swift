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
    internal var mockResponses = [Response]()
    
    // Private
    private var urlRequests = [URLRequest]()
    
    // MARK: Test helpers
    
    internal func numberOfRequests(matching pattern: String) -> Int
    {
        let count = self.urlRequests.filter { (urlRequest) -> Bool in
            let urlString = urlRequest.url?.absoluteString ?? ""
            return urlString.range(of: pattern, options: .regularExpression) != nil
        }.count
        
        return count
    }
    
    // MARK: URLSession
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    {
        self.urlRequests.append(request)
        
        // Find mock response
        let matchedResponse = self.mockResponses.first { (response) -> Bool in
            let urlString = request.url?.absoluteString ?? ""
            return urlString.range(of: response.urlPattern, options: .regularExpression) != nil
        }
        
        guard let unwrappedMockResponse = matchedResponse else
        {
            return EmptyTask()
        }
        
        return Task(request: request, response: unwrappedMockResponse, completionHandler: completionHandler)
    }
}


// MARK: Response

internal extension MockSession
{
    internal struct Response
    {
        internal let urlPattern: String
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
    
    internal class EmptyTask: URLSessionDataTask
    {
        internal override func resume() { }
    }
}
