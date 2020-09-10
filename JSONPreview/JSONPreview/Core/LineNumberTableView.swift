//
//  LineNumberTableView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - TableView

final class LineNumberTableView: UITableView {

    static let tag = 1
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
}

private extension LineNumberTableView {
    
    /// 配置
    func config() {
        
        tag = Self.tag
        
        delaysContentTouches = false
        canCancelContentTouches = true
        
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
        isScrollEnabled = false
        bounces = false
    }
}

// MARK: - Cell

final class LineNumberTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    /// Label for show line numbers
    lazy var numberLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .right
        label.numberOfLines = 1
        
        return label
    }()
}

private extension LineNumberTableViewCell {
    
    func config() {
        
        backgroundColor = .clear
        
        contentView.addSubview(numberLabel)
        
        let left = NSLayoutConstraint(item: numberLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 5)
        let right = NSLayoutConstraint(item: numberLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -5)
        
        let top = NSLayoutConstraint(item: numberLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: numberLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        contentView.addConstraints([left, right, top, bottom])
    }
}
