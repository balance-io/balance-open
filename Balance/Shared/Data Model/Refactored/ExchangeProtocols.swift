//
//  ExchangeApi2.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public typealias ExchangeApiOperationCompletionHandler = (_ success: Bool, _ error: ExchangeError?, _ data: [Any]) -> Void

public enum ExchangeError: Error {
    case invalidCredentials
    case other
}

public protocol ExchangeApi2 {
    func fetchData(for action: APIAction, completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation
}
