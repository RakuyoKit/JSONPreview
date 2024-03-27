//
//  ListTableViewCell.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

final class ListTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Config

private extension ListTableViewCell {
    func config() {
        detailTextLabel?.numberOfLines = 0
        
#if !os(tvOS)
        if #available(iOS 13.0, *) {
            detailTextLabel?.textColor = .secondaryLabel
        }
#endif
    }
}
