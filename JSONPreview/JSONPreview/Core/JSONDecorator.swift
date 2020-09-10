//
//  JSONDecorator.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Responsible for beautifying JSON
public class JSONDecorator {
    
    /// Highlight the incoming JSON string.
    ///
    /// Serve for `JSONPreview`. Will split JSON into arrays that meet the requirements of `JSONPreview` display.
    ///
    /// - Parameters:
    ///   - json: The JSON string to be highlighted.
    ///   - judgmentValid: Whether to check the validity of JSON.
    ///   - style: style of highlight. See `HighlightStyle` for details.
    /// - Returns: Return `nil` when JSON is invalid, otherwise return `[JSONSlice]`. See `JSONSlice` for details.
    static func highlight(_ json: String, judgmentValid: Bool, style: HighlightStyle = .default) -> [JSONSlice]? {
        
        guard let data = json.data(using: .utf8),
            let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            
            return nil
        }
        
        return highlight(json, style: style)
    }
    
    /// Highlight the incoming JSON string.
    ///
    /// Serve for `JSONPreview`. Will split JSON into arrays that meet the requirements of `JSONPreview` display.
    ///
    /// - Parameters:
    ///   - json: The JSON string to be highlighted.
    ///   - style: style of highlight. See `HighlightStyle` for details.
    /// - Returns: See `JSONSlice` for details.
    static func highlight(_ json: String, style: HighlightStyle = .default) -> [JSONSlice] {
        
        var slices: [JSONSlice] = []
        
        // Record indentation level
        var level = 0
        
        
        
        
        
        return slices
    }
}
