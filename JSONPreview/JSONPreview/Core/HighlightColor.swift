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
    let keyWord: UIColor
    
    /// The color of the key of the object
    let key: UIColor
    
    /// The color of the link in the object value
    let link: UIColor
    
    /// The color of the string in the object value
    let string: UIColor
    
    /// The color of the number in the object value
    let number: UIColor
    
    /// The background color of the JSON preview area
    let jsonBackground: UIColor
    
    /// The background color of the line number area
    let lineBackground: UIColor
    
    /// Text color in line number area
    let lineText: UIColor
}
