//
//  NSURLRequest.swift
//  BalanceForBlockchain
//
//  Created by Raimon Lapuente on 14/06/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func setHeaders(headers:[String:String]) {
        for header in headers {
            self.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
