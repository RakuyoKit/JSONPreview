//
//  Dictionary+Sort.swift
//  JSONPreview
//
//  Created by Rakuyo on 2022/5/30.
//  Copyright © 2022 Rakuyo. All rights reserved.
//

import Foundation

extension Dictionary where Key == JSONObjectKey, Value == JSONValue {
    /// Put the `.unknown` value in last place.
    ///
    /// Returns a sorted array of keys,
    /// conforming to the following rules:
    ///
    /// 1. If `JSONValue.unknown` exists, then it will be the last one in the array.
    /// 2. The remaining elements will be sorted by `<`.
    func rankingUnknownKeyLast() -> [Key] {
        guard !isEmpty else { return [] }
        
        var unknownKey: Key? = nil
        
        let otherKeys = keys.drop { key in
            guard case .unknown = self[key] else { return false }
            unknownKey = key
            return true
        }
        
        var result = Array(otherKeys).sorted(by: <)
        
        if let unknownKey = unknownKey {
            result.append(unknownKey)
        }
        
        return result
    }
}
