//
//  LineNumberTableView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

open class LineNumberTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
}

private extension LineNumberTableView {
    func config() {
        bounces = false
        delaysContentTouches = false
        canCancelContentTouches = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        
        allowsMultipleSelection = true
        estimatedRowHeight = 0
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        
#if !os(tvOS)
        scrollsToTop = false
        separatorStyle = .none
#endif
    }
}
