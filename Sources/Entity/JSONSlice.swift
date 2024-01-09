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
    public enum State: Hashable {
        public static let `default`: Self = .expand
        
        case expand, folded
    }
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - level: Indentation level.
    ///   - lineNumber: Position in the complete structure.
    ///   - state: The current display state of the slice.
    ///   - expand: The complete content of the JSON slice in the expanded state.
    ///   - folded: The summary content of the JSON slice in the folded state.
    ///   - foldedTimes: The number of times the slice was folded.
    internal init(
        level: Int,
        lineNumber: Int,
        state: State = .`default`,
        expand: AttributedString,
        folded: AttributedString? = nil,
        foldedTimes: Int = 0
    ) {
        self.level = level
        self.lineNumber = lineNumber
        self.state = state
        self.expand = expand
        self.folded = folded
        self.foldedTimes = foldedTimes
    }
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - level: Indentation level.
    ///   - lineNumber: Position in the complete structure.
    ///   - state: The current display state of the slice.
    ///   - expand: The complete content of the JSON slice in the expanded state.
    ///   - folded: The summary content of the JSON slice in the folded state.
    ///   - foldedTimes: The number of times the slice was folded.
    internal init(
        level: Int,
        lineNumber: Int,
        state: State = .`default`,
        expand: (String, StyleInfos),
        folded: (String, StyleInfos)? = nil,
        foldedTimes: Int = 0
    ) {
        self.init(
            level: level,
            lineNumber: lineNumber, 
            state: state,
            expand: .init(string: expand.0, attributes: expand.1),
            folded: folded.flatMap { .init(string: $0.0, attributes: $0.1) },
            foldedTimes: foldedTimes
        )
    }
    
    /// Position in the complete structure.
    public let lineNumber: Int
    
    /// The current display state of the slice.
    public var state: State
    
    /// Indentation level.
    public let level: Int
    
    /// The complete content of the JSON slice in the expanded state.
    public var expand: AttributedString
    
    /// The summary content of the JSON slice in the folded state.
    public var folded: AttributedString?
    
    /// The number of times the slice was folded.
    ///
    /// The initial value is 0, which means it is not folded.
    /// Each time the slice is folded, the value increases by 1.
    ///
    /// Mainly used to assist in calculating click positions.
    internal var foldedTimes: Int
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
