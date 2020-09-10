//
//  JSONPreviewTableView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - TableView

final class JSONPreviewTableView: UITableView {
    
    static let tag = 2
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
}

private extension JSONPreviewTableView {
    
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
        
        backgroundView = nil
        
        separatorStyle = .none
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        scrollsToTop = false
        isScrollEnabled = false
        bounces = false
    }
}

// MARK: - Cell

final class JSONPreviewTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    /// A label with JSON content
    lazy var jsonLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .left
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    override var tag: Int {
        didSet { jsonLabel.tag = tag }
    }
}

private extension JSONPreviewTableViewCell {
    
    func config() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        selectionStyle = .none
        
        contentView.addSubview(jsonLabel)
        
        let left = NSLayoutConstraint(item: jsonLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 5)
        let right = NSLayoutConstraint(item: jsonLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1, constant: -5)
        
        let top = NSLayoutConstraint(item: jsonLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: jsonLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        contentView.addConstraints([left, right, top, bottom])
        
        jsonLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}
