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
    
    public init(
        keyWord: UIColor,
        key: UIColor,
        link: UIColor,
        string: UIColor,
        number: UIColor,
        jsonBackground: UIColor,
        lineBackground: UIColor,
        lineText: UIColor
    ) {
        self.keyWord = keyWord
        self.key = key
        self.link = link
        self.string = string
        self.number = number
        self.jsonBackground = jsonBackground
        self.lineBackground = lineBackground
        self.lineText = lineText
    }
    
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

public extension HighlightColor {
    
    typealias ColorTuple = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    
    init(
        keyWord: ColorTuple,
        key: ColorTuple,
        link: ColorTuple,
        string: ColorTuple,
        number: ColorTuple,
        jsonBackground: ColorTuple,
        lineBackground: ColorTuple,
        lineText: ColorTuple
    ) {
        
        self.keyWord = UIColor(keyWord)
        self.key = UIColor(key)
        self.link = UIColor(link)
        self.string = UIColor(string)
        self.number = UIColor(number)
        self.jsonBackground = UIColor(jsonBackground)
        self.lineBackground = UIColor(lineBackground)
        self.lineText = UIColor(lineText)
    }
    
    typealias ColorHexTuple = (hex: Int, alpha: CGFloat)
    
    init(
        keyWord: ColorHexTuple,
        key: ColorHexTuple,
        link: ColorHexTuple,
        string: ColorHexTuple,
        number: ColorHexTuple,
        jsonBackground: ColorHexTuple,
        lineBackground: ColorHexTuple,
        lineText: ColorHexTuple
    ) {
        
        self.keyWord = UIColor(hex: keyWord.hex, alpha: keyWord.alpha)
        self.key = UIColor(hex: key.hex, alpha: key.alpha)
        self.link = UIColor(hex: link.hex, alpha: link.alpha)
        self.string = UIColor(hex: string.hex, alpha: string.alpha)
        self.number = UIColor(hex: number.hex, alpha: number.alpha)
        self.jsonBackground = UIColor(hex: jsonBackground.hex, alpha: jsonBackground.alpha)
        self.lineBackground = UIColor(hex: lineBackground.hex, alpha: lineBackground.alpha)
        self.lineText = UIColor(hex: lineText.hex, alpha: lineText.alpha)
    }
}

fileprivate extension UIColor {
    
    convenience init(_ colorTuple: HighlightColor.ColorTuple) {
        self.init(red: colorTuple.red, green: colorTuple.green, blue: colorTuple.blue, alpha: colorTuple.alpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
