//
//  TypeAliases.swift
//  Bal
//
//  Created by Benjamin Baron on 7/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Various completion handlers depending on the data
typealias SuccessErrorHandler = (_ success: Bool, _ error: Error?) -> Void
typealias SuccessErrorsHandler = (_ success: Bool, _ errors: [Error]?) -> Void
