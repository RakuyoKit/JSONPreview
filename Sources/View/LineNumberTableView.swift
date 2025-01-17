//
//  LineNumberTableView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - LineNumberTableView

open class LineNumberTableView: UITableView {
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
}

extension LineNumberTableView {
    private func config() {
        bounces = false
        delaysContentTouches = false
        canCancelContentTouches = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        allowsMultipleSelection = true
        contentInsetAdjustmentBehavior = .never
        
        estimatedRowHeight = 0.0
        estimatedSectionFooterHeight = 0.0
        estimatedSectionHeaderHeight = 0.0
        
        if #available(iOS 15.0, tvOS 15.0, *) {
            sectionHeaderTopPadding = 0.0
        }
        
        #if !os(tvOS)
        scrollsToTop = false
        separatorStyle = .none
        #endif
    }
}
