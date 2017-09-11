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
}
