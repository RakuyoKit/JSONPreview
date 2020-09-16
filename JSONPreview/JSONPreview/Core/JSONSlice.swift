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
    
    /// The current display state of the slice
    public enum State {
        case expand, folded
    }
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - level: Indentation level.
    ///   - lineNumber: Position in the complete structure.
    ///   - expand: The complete content of the JSON slice in the expanded state.
    ///   - folded: The summary content of the JSON slice in the folded state.
    public init(
        level: Int,
        lineNumber: Int,
        expand: NSAttributedString,
        folded: NSAttributedString? = nil
    ) {
        
        self.state = .expand
        self.isHidden = false
        self.level = level
        self.lineNumber = lineNumber
        self.expand = expand
        self.folded = folded
    }
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - level: Indentation level.
    ///   - lineNumber: Position in the complete structure.
    ///   - expand: The complete content of the JSON slice in the expanded state.
    ///   - folded: The summary content of the JSON slice in the folded state.
    public init(
        level: Int,
        lineNumber: Int,
        expand: (String, [NSAttributedString.Key : Any]),
        folded: (String, [NSAttributedString.Key : Any])? = nil
    ) {
        
        self.state = .expand
        self.isHidden = false
        self.level = level
        self.lineNumber = lineNumber
        
        self.expand = NSAttributedString(string: expand.0, attributes: expand.1)
        
        if let folded = folded {
            self.folded = NSAttributedString(string: folded.0, attributes: folded.1)
        } else {
            self.folded = nil
        }
    }
    
    /// The current display state of the slice. The default is `.expand`.
    public var state: State
    
    /// Is it hidden
    public var isHidden: Bool
    
    /// Position in the complete structure.
    public let lineNumber: Int
    
    /// Indentation level.
    public let level: Int
    
    /// The complete content of the JSON slice in the expanded state.
    public var expand: NSAttributedString
    
    /// The summary content of the JSON slice in the folded state.
    public var folded: NSAttributedString?
}

public extension JSONSlice {
    
    /// According to different status, return the content that should be displayed currently.
    var showContent: NSAttributedString? {
        
        switch state {
        case .expand: return expand
        case .folded: return folded
        }
    }
}
