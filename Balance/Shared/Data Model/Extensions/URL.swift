//
//  URL.swift
//  Bal
//
//  Created by Benjamin Baron on 6/28/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension URL {
    
    var queryParameters: [String: String] {
        var parameters = [String: String]()
        let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems
        queryItems?.forEach({parameters[$0.name] = $0.value})
        return parameters
    }
    
    func addQueryParams(_ newParams: [String: String]) -> URL? {
        guard let urlComponents = NSURLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        let extraQuery = newParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        if let actualQueryItems = urlComponents.queryItems {
            let completeQuery = actualQueryItems + extraQuery
            urlComponents.queryItems = completeQuery
        } else {
            urlComponents.queryItems?.append(contentsOf: extraQuery)
        }
        
        return urlComponents.url
    }
    
}
