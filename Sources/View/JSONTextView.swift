//
//  JSONTextView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/12.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - JSONTextViewDelegate

@available(
    tvOS,
    unavailable,
    message: "UITextView cannot be edited on tvOS, so the folding function cannot be implemented."
)
public protocol JSONTextViewDelegate: NSObjectProtocol {
    /// Execute when zoom is triggered.
    ///
    /// - Parameters:
    ///   - textView: Currently displayed textView.
    ///   - pointY: Y value of the clicked coordinate.
    func textView(_ textView: JSONTextView, didClickZoomAt pointY: CGFloat)
}

// MARK: - JSONTextView

open class JSONTextView: UITextView {
    #if !os(tvOS)
    /// Used for callback click
    open weak var clickDelegate: JSONTextViewDelegate? = nil
    #endif
    
    override public init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
}

// MARK: - Life cycle

extension JSONTextView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // When JSON is folded and expanded, the `textStorage.replaceCharacters`
        // method is called back, which triggers the redrawing of UITextView,
        // causing `contentOffset.y` to shift.
        //
        // Because the current UITextView is a subview of UIScrollView,
        // this offset will cause confusion in the UI interface.
        //
        // And because UITextView does not participate in sliding,
        // we can manually fix the value of `contentOffset.y` to `0` forever.
        contentOffset.y = 0
    }
}

// MARK: - Config

extension JSONTextView {
    private func config() {
        delaysContentTouches = false
        canCancelContentTouches = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        textAlignment = .left
        linkTextAttributes = [:]
        textContainer.lineFragmentPadding = 0
        layoutManager.allowsNonContiguousLayout = false
        
        #if !os(tvOS)
        isEditable = false
        #endif
    }
}

// MARK: -

extension JSONTextView {
    #if !os(tvOS)
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer { super.touchesBegan(touches, with: event) }
        
        // Get the letter of the character at the current touch position
        guard let touch = touches.randomElement() else { return }
        
        let point = touch.location(in: self)
        
        // Get the position of the clicked letter
        let characterIndex = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        let startIndex = text.startIndex
        
        // Prevent the click logic from triggering when the line break is clicked.
        let index = text.index(startIndex, offsetBy: characterIndex)
        guard index < text.endIndex, text[index] != "\n" else { return }
        
        let callbackBlock = {
            self.clickDelegate?.textView(self, didClickZoomAt: point.y)
        }
        
        // Clicked on the fold area
        if attributedText.attribute(.backgroundColor, at: characterIndex, effectiveRange: nil) != nil {
            callbackBlock()
            return
        }
        
        // Blur the scope of the click.
        for index in -1 ... 2 {
            let offset = characterIndex + index
            
            guard offset >= 0 && offset < text.count else { break }
            
            let char = text[text.index(startIndex, offsetBy: offset)]
            
            guard char == "[" || char == "{" else { continue }
            
            callbackBlock()
            break
        }
    }
    #endif
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(cut(_:)): return false
        case #selector(paste(_:)): return false
        case #selector(select(_:)): return false
        case #selector(delete(_:)): return false
        case #selector(copy(_:)): return true
        case #selector(selectAll(_:)): return true
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    override open func copy(_ sender: Any?) {
        super.copy(sender)
        
        selectedTextRange = nil
    }
}
