//
//  LockedDictionary.swift
//  
//
//  Created by Stanislav Kobiletski on 14.06.2020.
//

import Foundation

struct LockedDictionary<Key: Hashable, Value> {
  
  private let lock = NSLock()
  private var backing: [Key: Value] = [:]
  
  subscript(key: Key) -> Value? {
    get {
      lock.lock()
      defer { lock.unlock() }
      
      return backing[key]
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      
      backing[key] = newValue
    }
  }
}

// MARK: - ExpressibleByDictionaryLiteral
extension LockedDictionary: ExpressibleByDictionaryLiteral {
  
  init(dictionaryLiteral elements: (Key, Value)...) {
    for (key, value) in elements {
      backing[key] = value
    }
  }
}
