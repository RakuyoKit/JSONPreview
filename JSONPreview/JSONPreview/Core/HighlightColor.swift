//
//  HighlightColor.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Color configuration for highlight
public struct HighlightColor {
    
    /// Keyword color. Including `{}`, `[]`, `:`, `,`
    public let keyWord: UIColor
    
    /// The color of the key of the object
    public let key: UIColor
    
    /// The color of the link in the object value
    public let link: UIColor
    
    /// The color of the string in the object value
    public let string: UIColor
    
    /// The color of the number in the object value
    public let number: UIColor
    
    /// The background color of the JSON preview area
    public let jsonBackground: UIColor
    
    /// The background color of the line number area
    public let lineBackground: UIColor
    
    /// Text color in line number area
    public let lineText: UIColor
}
