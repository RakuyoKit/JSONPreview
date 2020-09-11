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
        key: [0.72, 0.18, 0.13],
        link: [0.12, 0.29, 0.61],
        string: [0.18, 0.41, 0.30],
        number: [0.80, 0.57, 0.08],
        
        boolean: [0.80, 0.57, 0.08],
        null: [0.80, 0.57, 0.08],
        unknownText: [0.80, 0.57, 0.08],
        unknownBackground: [0.80, 0.57, 0.08],
        
        jsonBackground: UIColor.white,
        lineBackground: [0.93, 0.93, 0.93],
        lineText: [0.64, 0.64, 0.64]
    )
    
    /// Built-in dark mode.
    static let dark = HighlightColor(
        keyWord: 0x5E7987,
        key: 0xC04851,
        link: 0x5497C7,
        string: 0x248067,
        number: 0xCC9114,
        
        boolean: [0.80, 0.57, 0.08],
        null: [0.80, 0.57, 0.08],
        unknownText: [0.80, 0.57, 0.08],
        unknownBackground: [0.80, 0.57, 0.08],
        
        jsonBackground: 0x0F2E41,
        lineBackground: 0x082332,
        lineText: 0x20455C
    )
    
    /// A darker color scheme that the author likes.
    static let mariana = HighlightColor(
        keyWord: 0x88B0BF,
        key: 0xF2777B,
        link: 0x73AAD4,
        string: 0xA3D0A5,
        number: 0xF9BC6B,
        
        boolean: [0.80, 0.57, 0.08],
        null: [0.80, 0.57, 0.08],
        unknownText: [0.80, 0.57, 0.08],
        unknownBackground: [0.80, 0.57, 0.08],
        
        jsonBackground: 0x3E444C,
        lineBackground: 0x363C43,
        lineText: 0x88B0BF
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
        
        let red   = CGFloat((self & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((self & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat(self & 0xFF) / 255.0
        
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
        
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat(hex & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

/// Like `[0.72, 0.18, 0.13]`. Will not check for out-of-bounds behavior.
extension Array: ConvertibleToColor where Element == CGFloat {
    
    public var color: UIColor {
        return UIColor(red: self[0], green: self[1], blue: self[2], alpha: 1)
    }
}
