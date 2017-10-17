//
//  SimpleCache.swift
//  BalanceServer
//
//  Created by Benjamin Baron on 10/15/17.
//

import Foundation

public class SimpleCache<KeyType: Hashable, ValueType: Any> {
    fileprivate var cache = [KeyType: ValueType]()
    fileprivate let lock = NSLock()
    
    public func getAll() -> [KeyType: ValueType] {
        return cache
    }

    public func get(valueForKey key: KeyType) -> ValueType? {
        var value: ValueType?
        lock.lock()
        value = cache[key]
        lock.unlock()
        return value
    }
    
    public func set(value: ValueType?, forKey key: KeyType) {
        lock.lock()
        cache[key] = value
        lock.unlock()
    }
    
    public func remove(valueForKey key: KeyType) {
        lock.lock()
        cache.removeValue(forKey: key)
        lock.unlock()
    }
    
    public func removeAll() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }
}
