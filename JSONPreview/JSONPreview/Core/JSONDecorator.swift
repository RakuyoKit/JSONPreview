//
//  JSONDecorator.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// Responsible for beautifying JSON
public class JSONDecorator {
    
    /// Highlight the incoming JSON string.
    ///
    /// Serve for `JSONPreview`. Will split JSON into arrays that meet the requirements of `JSONPreview` display.
    ///
    /// - Parameters:
    ///   - json: The JSON string to be highlighted.
    ///   - judgmentValid: Whether to check the validity of JSON.
    /// - Returns: Return `nil` when JSON is invalid, otherwise return `[JSONSlice]`. See `JSONSlice` for details.
    static func highlight(_ json: String, judgmentValid: Bool) -> [JSONSlice]? {
        
        guard let data = json.data(using: .utf8),
            let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            
            return nil
        }
        
        return highlight(json)
    }
    
    /// Highlight the incoming JSON string.
    ///
    /// Serve for `JSONPreview`. Will split JSON into arrays that meet the requirements of `JSONPreview` display.
    ///
    /// - Parameter json: The JSON string to be highlighted.
    /// - Returns: See `JSONSlice` for details.
    static func highlight(_ json: String) -> [JSONSlice] {
        
        var slices: [JSONSlice] = []
        
        // Record indentation level
        var level = 0
        
        
        
        
        
        return slices
    }
}
