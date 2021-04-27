//
//  JSONTextView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/12.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol JSONTextViewClickDelegate: AnyObject {
    
    /// Execute when zoom is triggered.
    ///
    /// - Parameters:
    ///   - textView: Currently displayed textView.
    ///   - pointY: Y value of the clicked coordinate.
    func textView(_ textView: JSONTextView, didClickZoomAt pointY: CGFloat)
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
        
        linkTextAttributes = [:]
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
        
        let startIndex = text.startIndex
        
        // Prevent the click logic from triggering when the line break is clicked.
        guard text[text.index(startIndex, offsetBy: characterIndex)] != "\n" else { return }
        
        let callbackBlock = {
            self.clickDelegate?.textView(self, didClickZoomAt: point.y)
        }
        
        // Clicked on the fold area
        if attributedText.attribute(.backgroundColor, at: characterIndex, effectiveRange: nil) != nil {
            callbackBlock()
            return
        }
        
        // Blur the scope of the click.
        for i in -1 ... 2 {
            
            let offset = characterIndex + i
            
            guard offset >= 0 && offset < text.count else { break }
            
            let char = text[text.index(startIndex, offsetBy: offset)]
            
            guard char == "[" || char == "{" else { continue }
            
            callbackBlock()
            break
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
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
    
    open override func copy(_ sender: Any?) {
        super.copy(sender)
        
        selectedTextRange = nil
    }
}
