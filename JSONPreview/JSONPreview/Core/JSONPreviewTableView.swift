//
//  JSONPreviewTableView.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - TableView

open class JSONPreviewTableView: UITableView {
    
    public static let tag = 2
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
}

private extension JSONPreviewTableView {
    
    func config() {
        
        tag = Self.tag
        
        delaysContentTouches = false
        canCancelContentTouches = true
        translatesAutoresizingMaskIntoConstraints = false
        
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

open class JSONPreviewCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }

    public required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
    
    /// `UITextView` for displaying json content
    open lazy var jsonView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.backgroundColor = .clear
        
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = false
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        
        return textView
    }()
}

extension JSONPreviewCell {
    
    private func config() {
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(jsonView)
        
        NSLayoutConstraint.activate([
            jsonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            jsonView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            jsonView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
        ])
        
        jsonView.setContentHuggingPriority(.required, for: .vertical)
    }
}
