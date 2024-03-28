//
//  AttributedStringSizeCalculator.swift
//  JSONPreview
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

/// Utility class for calculating attributed string size.
internal class AttributedStringSizeCalculator {
    typealias SliceState = JSONSlice.State
    
    private typealias Storage = [Int: [SliceState: CGFloat]]
    
    /// Because the height of a single JSON slice will be obtained multiple times,
    /// caching is used to improve reading efficiency and reduce repeated calculations.
    private lazy var cachedHeight: [Orientation: Storage] = Orientation
        .allCases
        .reduce(into: [:], { $0[$1] = [:] })
}

// MARK: - Height

extension AttributedStringSizeCalculator {
    /// Calculate the line height of the line number display area
    func calculateHeight(with slice: JSONSlice, width: CGFloat? = nil) -> CGFloat {
        let attString: AttributedString = {
            switch slice.state {
            case .expand: return slice.expand
            case .folded: return slice.folded ?? slice.expand
            }
        }()
        
        let size = calculateSize(with: attString, width: width)
        return size.height
    }
    
    func cache(_ height: CGFloat, at line: Int, orientation: Orientation, state: SliceState) {
        guard let orientationValue = cachedHeight[orientation] else { return }
        
        guard let lineValue = orientationValue[line] else {
            cachedHeight[orientation] = [line: [state: height]]
            return
        }
        
        guard lineValue[state] != nil else {
            cachedHeight[orientation]?[line] = [state: height]
            return
        }
        
        cachedHeight[orientation]?[line]?[state] = height
    }
    
    func height(at line: Int, orientation: Orientation, state: SliceState) -> CGFloat? {
        guard let orientationValue = cachedHeight[orientation] else { return nil }
        
        guard
            let lineValue = orientationValue[line],
            let stateValue = lineValue[state]
        else {
            return nil
        }
        
        return stateValue
    }
    
    func clearCachedHeight() {
        cachedHeight.removeAll()
    }
}

// MARK: - Size

extension AttributedStringSizeCalculator {
    /// Calculate the size of a rich text string in a container
    func calculateSize(
        with attributedString: AttributedString,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> CGSize {
        let size = CGSize(
            width: width ?? .greatestFiniteMagnitude,
            height: height ?? .greatestFiniteMagnitude
        )
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        layoutManager.glyphRange(
            forBoundingRect: CGRect(origin: .zero, size: size),
            in: textContainer
        )
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)
        
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size
    }
}
