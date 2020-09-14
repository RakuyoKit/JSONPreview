//
//  JSONTextView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/12.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol JSONTextViewClickDelegate: class {
    
    /// Execute when zoom is triggered
    ///
    /// - Parameters:
    ///   - textView: Currently displayed textView
    ///   - pointY: Y value of the clicked coordinate
    ///   - characterIndex: The index of the clicked character in the string
    func textView(_ textView: JSONTextView, didClickZoomAt pointY: CGFloat, characterIndex: Int)
}

open class JSONTextView: UITextView {
    
    public override init(frame: CGRect, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    /// Used for callback click
    open weak var clickDelegate: JSONTextViewClickDelegate? = nil
}

private extension JSONTextView {
    
    func config() {
        
        delaysContentTouches = false
        canCancelContentTouches = true
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        
        textAlignment = .left
        isEditable = false
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        scrollsToTop = false
        isScrollEnabled = false
        bounces = false
        
        textContainer.lineFragmentPadding = 0
        layoutManager.allowsNonContiguousLayout = false
    }
}

extension JSONTextView {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        defer {
            super.touchesBegan(touches, with: event)
        }
        
        // Get the letter of the character at the current touch position
        guard let touch = touches.randomElement() else { return }
        
        let point = touch.location(in: self)
        
        // Get the position of the clicked letter
        let characterIndex = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        let callbackBlock = {
            self.clickDelegate?.textView(self, didClickZoomAt: point.y, characterIndex: characterIndex)
        }
        
        // Clicked on the fold area
        if attributedText.attribute(.backgroundColor, at: characterIndex, effectiveRange: nil) != nil {
            callbackBlock()
            return
        }
        
        guard characterIndex + 2 < text.count else { return }
        
        let char = text[text.index(text.startIndex, offsetBy: characterIndex + 2)]
        
        if char == "[" || char == "{" {
            callbackBlock()
            return
        }
        
        guard characterIndex + 3 < text.count else { return }
        
        let _char = text[text.index(text.startIndex, offsetBy: characterIndex + 3)]
        
        if _char == "[" || _char == "{" {
            callbackBlock()
            return
        }
        
        let __char = text[text.index(text.startIndex, offsetBy: characterIndex + 1)]
        
        if __char == "[" || __char == "{" {
            callbackBlock()
            return
        }
    }
}
