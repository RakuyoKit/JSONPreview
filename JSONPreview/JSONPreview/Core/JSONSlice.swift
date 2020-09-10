//
//  JSONSlice.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// Used to represent a certain part of JSON
public struct JSONSlice {
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - level: Indentation level.
    ///   - expand: The complete content of the JSON slice in the expanded state.
    ///   - folded: The summary content of the JSON slice in the folded state.
    public init(
        level: Int,
        expand: NSAttributedString,
        folded: NSAttributedString? = nil
    ) {
        
        self.isFolded = false
        self.level = level
        self.expand = expand
        self.folded = folded
    }
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - level: Indentation level.
    ///   - expand: The complete content of the JSON slice in the expanded state.
    ///   - folded: The summary content of the JSON slice in the folded state.
    public init(
        level: Int,
        expand: (String, [NSAttributedString.Key : Any]),
        folded: (String, [NSAttributedString.Key : Any])? = nil
    ) {
        
        self.isFolded = false
        self.level = level
        
        self.expand = NSAttributedString(string: expand.0, attributes: expand.1)
        
        if let folded = folded {
            self.folded = NSAttributedString(string: folded.0, attributes: folded.1)
        } else {
            self.folded = nil
        }
    }
    
    /// Whether it is currently folded.
    public var isFolded: Bool
    
    /// Indentation level.
    public var level: Int
    
    /// The complete content of the JSON slice in the expanded state.
    public var expand: NSAttributedString
    
    /// The summary content of the JSON slice in the folded state.
    public var folded: NSAttributedString?
}
