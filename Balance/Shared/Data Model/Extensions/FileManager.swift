//
//  FileManager.swift
//  Bal
//
//  Created by Benjamin Baron on 3/1/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension FileManager {
    func fileExists(atURL url: URL) -> Bool {
        return url.isFileURL ? fileExists(atPath: url.path) : false
    }
    
    func fileSize(atURL url: URL) -> Int {
        return url.isFileURL ? fileSize(atPath: url.path) : 0
    }
    
    func fileSize(atPath path: String) -> Int {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let size = attributes[FileAttributeKey.size] as? Int {
                return size
            } else {
                print("Failed to get a size attribute from path: \(path)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(path) with error: \(error)")
        }
        
        return 0
    }
}
