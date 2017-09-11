//
// Created by Sam Duke on 15/06/2016.
// Copyright (c) 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class PlaidDataMockingProtocol: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    override func startLoading() {
        // path component 0 is '/'
        switch (self.request.url!.pathComponents[1]) {
            case "categories":
                let loadedData = SampleResponses.getFullCategoriesResponse().data(using: String.Encoding.utf8, allowLossyConversion: false)
                let response = HTTPURLResponse(url: self.request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json; charset=utf-8"])
                self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: loadedData!)
                self.client?.urlProtocolDidFinishLoading(self)
                break
            default:
                //explode
                let response = HTTPURLResponse(url: self.request.url!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json; charset=utf-8"])
                self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocolDidFinishLoading(self)
                break
        }
    }

    override func stopLoading() {

    }


}
