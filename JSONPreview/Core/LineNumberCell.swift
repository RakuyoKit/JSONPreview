//
//  LineNumberCell.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/10/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class LineNumberCell: UITableViewCell {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Modify the left spacing of the label.
        textLabel?.frame.origin.x = 5
        
        // Modify the width, actually in order to modify the right spacing.
        textLabel?.frame.size.width = contentView.frame.size.width - 15
        
        // Make label ceiling display
        if let height = textLabel?.sizeThatFits(contentView.frame.size).height {
            textLabel?.frame.size.height = height
        }
    }
}
