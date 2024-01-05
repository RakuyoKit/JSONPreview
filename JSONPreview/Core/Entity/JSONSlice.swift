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
        expand: AttributedString,
        folded: AttributedString? = nil
    ) {
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
        expand: (String, StyleInfos),
        folded: (String, StyleInfos)? = nil
    ) {
        self.init(
            level: level,
            lineNumber: lineNumber, 
            expand: .init(string: expand.0, attributes: expand.1),
            folded: folded.flatMap { .init(string: $0.0, attributes: $0.1) }
        )
    }
    
    /// The current display state of the slice. The default is `.expand`.
    public var state: State = .expand
    
    /// The number of times the slice was folded.
    ///
    /// The initial value is 0, which means it is not folded.
    /// Each time the slice is folded, the value increases by 1.
    public var foldedTimes: Int = 0
    
    /// Position in the complete structure.
    public let lineNumber: Int
    
    /// Indentation level.
    public let level: Int
    
    /// The complete content of the JSON slice in the expanded state.
    public var expand: AttributedString
    
    /// The summary content of the JSON slice in the folded state.
    public var folded: AttributedString?
}

public extension JSONSlice {
    /// According to different status, return the content that should be displayed currently.
    var showContent: AttributedString? {
        switch state {
        case .expand: return expand
        case .folded: return folded
        }
    }
}
