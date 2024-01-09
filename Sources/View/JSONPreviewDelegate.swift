//
//  JSONPreviewDelegate.swift
//  JSONPreview
//
//  Created by Rakuyo on 2024/1/9.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

public protocol JSONPreviewDelegate: NSObjectProtocol {
    /// Callback executed when clicking on the URL on the view.
    ///
    /// - Parameters:
    ///   - view: The view itself for previewing the json.
    ///   - url: The URL address that the user clicked on.
    ///   - textView: The `UITextView` to which the URL belongs.
    /// - Returen: `true` if interaction with the URL should be allowed; `false` if interaction should not be allowed.
    func jsonPreview(_ view: JSONPreview, didClickURL url: URL, on textView: UITextView) -> Bool
    
    /// Callback when the status of the json slice node changes.
    ///
    /// - Parameters:
    ///   - view: The view itself for previewing the json.
    ///   - slice: Slice nodes whose status has changed.
    ///   - decorator: Stores the rendering result of the current JSON.
    func jsonPreview(_ view: JSONPreview, didChangeSliceState slice: JSONSlice, decorator: JSONDecorator)
}

// MARK: - Default

public extension JSONPreviewDelegate {
    func jsonPreview(_ view: JSONPreview, didClickURL url: URL, on textView: UITextView) -> Bool {
        return true
    }
    
    func jsonPreview(_ view: JSONPreview, didChangeSliceState slice: JSONSlice, decorator: JSONDecorator) { }
}
