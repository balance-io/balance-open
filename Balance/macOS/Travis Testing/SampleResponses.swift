//
//  SampleResponses.swift
//  Bal
//
//  Created by Sam Duke on 16/06/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class SampleResponses {

    class func getFullCategoriesResponse() -> String {
        return loadJsonStringFromFile("MockData/CategoriesFullResponse")
    }

    fileprivate class func loadJsonStringFromFile(_ fileName: String) -> String {
        if let filepath = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                return contents
            } catch {
                fatalError("File not found")
            }
        } else {
            fatalError("File not found")
        }
    }
}
