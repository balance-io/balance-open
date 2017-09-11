//
//  Data.swift
//  Bal
//
//  Created by Benjamin Baron on 11/14/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Int {
    var hex: String {
        return String(format: "%02X", self)
    }
}

extension Data {
    var hex: String {
        return self.map{Int($0).hex}.joined()
    }
    
    var md5: String {
        var result = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = result.withUnsafeMutableBytes { resultPtr in
            self.withUnsafeBytes { bytes in
                CC_MD5(bytes, CC_LONG(count), resultPtr)
            }
        }
        return result.hex
    }
    
    var sha1: String {
        var result = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        _ = result.withUnsafeMutableBytes { resultPtr in
            self.withUnsafeBytes() { bytes in
                CC_SHA1(bytes, CC_LONG(count), resultPtr)
            }
        }
        return result.hex
    }
    
    var sha256: String {
        var result = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = result.withUnsafeMutableBytes { resultPtr in
            self.withUnsafeBytes { bytes in
                CC_SHA256(bytes, CC_LONG(count), resultPtr)

            }
        }
        return result.hex
    }
}
