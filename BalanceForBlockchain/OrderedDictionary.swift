//
//  OrderedDictionary.swift
//  SwiftDataStructures
//
//  Created by Tim Ekl on 6/2/14.
//  Copyright (c) 2014 Tim Ekl. Available under MIT License. See LICENSE.md.
//

import Foundation

struct OrderedDictionary<Tk: Hashable, Tv> {
    var keys: Array<Tk> = []
    var values: Dictionary<Tk,Tv> = [:]
    
    var count: Int {
        assert(keys.count == values.count, "Keys and values array out of sync")
        return self.keys.count;
    }
    
    // Explicitly define an empty initializer to prevent the default memberwise initializer from being generated
    init() {}
    
    subscript(index: Int) -> Tv? {
        get {
            let key = self.keys[index]
            return self.values[key]
        }
        set(newValue) {
            let key = self.keys[index]
            if (newValue != nil) {
                self.values[key] = newValue
            } else {
                self.values.removeValue(forKey: key)
                self.keys.remove(at: index)
            }
        }
    }
    
    subscript(key: Tk) -> Tv? {
        get {
            return self.values[key]
        }
        set(newValue) {
            if newValue == nil {
                self.values.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            } else {
                let oldValue = self.values.updateValue(newValue!, forKey: key)
                if oldValue == nil {
                    self.keys.append(key)
                }
            }
        }
    }
    
    var description: String {
        var result = "{\n"
        for i in 0..<self.count {
            result += "[\(i)]: \(self.keys[i]) => \(String(describing: self[i]))\n"
        }
        result += "}"
        return result
    }
    
    var flattened: [Any] {
        var flattened = [Any]()
        for key in self.keys {
            flattened.append(key)
            if let value = self[key] {
                if let array = value as? [Any] {
                    for innerValue in array {
                        flattened.append(innerValue)
                    }
                } else if let array = value as? [AnyObject] {
                    for innerValue in array {
                        flattened.append(innerValue)
                    }
                } else if let array = value as? NSArray {
                    for innerValue in array {
                        flattened.append(innerValue)
                    }
                } else {
                    flattened.append(value)
                }
            }
        }
        return flattened
    }
    
//    var flattenedObjects: [AnyObject] {
//        var flattened = [AnyObject]()
//        for key in self.keys {
//            if let key = key as? AnyObject {
//                flattened.append(key)
//            }
//            
//            if let value = self[key] {
//                if let array = value as? [AnyObject] {
//                    flattened.append(contentsOf: array)
//                } else if let array = value as? NSArray {
//                    flattened.append(array)
//                } else if let object = value as? AnyObject {
//                    flattened.append(object)
//                }
//            }
//        }
//        return flattened
//    }
}
