//
//  HighlightStyle.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Highlight style configuration
public struct HighlightStyle {
    
    /// Expand the icon of the button. Default icon will be used when `nil`.
    public let expandIcon: UIImage?
    
    /// The icon of the fold button. Default icon will be used when nil
    public let foldedIcon: UIImage?
    
    /// Color-related configuration, see `HighlightColor` for details
    public let color: HighlightColor
}
