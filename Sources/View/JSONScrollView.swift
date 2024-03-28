//
//  JSONScrollView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2024/3/28.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

open class JSONScrollView: UIScrollView {
#if os(tvOS)
    open override var canBecomeFocused: Bool { true }
#endif
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    private func config() {
        contentInset = .zero
        delaysContentTouches = false
        canCancelContentTouches = true
        
#if os(tvOS)
        isUserInteractionEnabled = true
        panGestureRecognizer.allowedTouchTypes = [
            // swiftlint:disable:next legacy_objc_type
            NSNumber(value: UITouch.TouchType.indirect.rawValue)
        ]
#endif
    }
}
