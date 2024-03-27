//
//  String+Range.swift
//  JSONPreview
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import Foundation

extension String {
    func findNSRanges(of searchString: Self) -> [NSRange] {
        var results: [NSRange] = []
        var searchStartIndex = startIndex
        while let range = range(
            of: searchString,
            options: .literal,
            range: searchStartIndex ..< endIndex
        ) {
            defer {
                searchStartIndex = range.upperBound
            }
            guard
                let utf16LowerBound = range.lowerBound.samePosition(in: utf16),
                let utf16UpperBound = range.upperBound.samePosition(in: utf16)
            else {
                continue
            }
            let location = utf16.distance(from: utf16.startIndex, to: utf16LowerBound)
            let length = utf16.distance(from: utf16LowerBound, to: utf16UpperBound)
            let nsRange = NSRange(location: location, length: length)
            results.append(nsRange)
        }
        return results
    }
    
    private func findAllRanges(of searchString: Self) -> [Range<Self.Index>] {
        var ranges: [Range<Self.Index>] = []
        var searchStartIndex = startIndex
        while let range = range(
            of: searchString,
            options: .literal,
            range: searchStartIndex ..< endIndex
        ) {
            ranges.append(range)
            searchStartIndex = range.upperBound
        }
        return ranges
    }
    
    private func nsRange(from range: Range<Self.Index>) -> NSRange? {
        guard
            let utf16LowerBound = range.lowerBound.samePosition(in: utf16),
            let utf16UpperBound = range.upperBound.samePosition(in: utf16)
        else {
            return nil
        }
        
        let location = utf16.distance(from: utf16.startIndex, to: utf16LowerBound)
        let length = utf16.distance(from: utf16LowerBound, to: utf16UpperBound)
        
        return .init(location: location, length: length)
    }
}
