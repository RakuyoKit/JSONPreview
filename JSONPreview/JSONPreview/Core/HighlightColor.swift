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
        keyWord: ConvertibleToColor,
        key: ConvertibleToColor,
        link: ConvertibleToColor,
        string: ConvertibleToColor,
        number: ConvertibleToColor,
        boolean: ConvertibleToColor,
        null: ConvertibleToColor,
        unknownText: ConvertibleToColor,
        unknownBackground: ConvertibleToColor,
        jsonBackground: ConvertibleToColor,
        lineBackground: ConvertibleToColor,
        lineText: ConvertibleToColor
    ) {
        self.keyWord = keyWord.color
        self.key = key.color
        self.link = link.color
        self.string = string.color
        self.number = number.color
        self.boolean = boolean.color
        self.null = null.color
        self.unknownText = unknownText.color
        self.unknownBackground = unknownBackground.color
        self.jsonBackground = jsonBackground.color
        self.lineBackground = lineBackground.color
        self.lineText = lineText.color
    }
    
    /// Keyword color. Including `{}`, `[]`, `:`, `,`
    public let keyWord: UIColor
    
    /// The color of the key of the object
    public let key: UIColor
    
    /// The color of the link
    public let link: UIColor
    
    /// The color of the string
    public let string: UIColor
    
    /// The color of the number
    public let number: UIColor
    
    /// The color of the boolean
    public let boolean: UIColor
    
    /// The color of the null
    public let null: UIColor
    
    /// Text color of unknown type data
    public let unknownText: UIColor
    
    /// Background color of unknown type data
    public let unknownBackground: UIColor
    
    /// The background color of the JSON preview area
    public let jsonBackground: UIColor
    
    /// The background color of the line number area
    public let lineBackground: UIColor
    
    /// Text color in line number area
    public let lineText: UIColor
}

// MARK: - Built-in color style

public extension HighlightColor {
    /// Default color configuration.
    static let `default` = HighlightColor(
        keyWord: UIColor.black,
        key: 0xB72E22,
        link: 0x1E4A9C,
        string: 0x2D694C,
        number: 0xCC9115,
        boolean: 0x72AAD3,
        null: 0xEA2E22,
        unknownText: 0xD5412E,
        unknownBackground: 0xFBE3E4,
        jsonBackground: UIColor.white,
        lineBackground: 0xEDEDED,
        lineText: 0xA3A3A3
    )
    
    /// A darker color scheme that the author likes.
    static let mariana = HighlightColor(
        keyWord: 0x767677,
        key: 0xF2777B,
        link: 0x73AAD4,
        string: 0xA3D0A5,
        number: 0xF9BC6B,
        boolean: 0x88B0BF,
        null: 0xD16D71,
        unknownText: 0xD5412E,
        unknownBackground: 0xFBE3E4,
        jsonBackground: 0x3D444C,
        lineBackground: 0x363D42,
        lineText: 0x767677
    )
}

// MARK: - ConvertibleToColor

/// Used to convert some types to UIColor types
public protocol ConvertibleToColor {
    /// The converted color will be read through this attribute
    var color: UIColor { get }
}

extension UIColor: ConvertibleToColor {
    public var color: UIColor { self }
}

/// Like `0x88B0BF`
extension Int: ConvertibleToColor {
    public var color: UIColor {
        let red = CGFloat((self & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((self & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(self & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

/// Like `#FF7F20`
extension String: ConvertibleToColor {
    public var color: UIColor {
        let hex: Int = {
            var sum = 0
            
            uppercased().utf8.forEach {
                sum = sum * 16 + Int($0) - 48
                if $0 >= 65 { sum -= 7 }
            }
            
            return sum
        }()
        
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
