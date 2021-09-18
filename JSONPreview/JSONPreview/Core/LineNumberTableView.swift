//
//  LineNumberTableView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
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
    
    /// 配置
    func config() {
        delaysContentTouches = false
        canCancelContentTouches = true
        translatesAutoresizingMaskIntoConstraints = false
        
        estimatedRowHeight = 0
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        
        if #available(iOS 11, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        separatorStyle = .none
        
        allowsMultipleSelection = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        scrollsToTop = false
        bounces = false
    }
}
