//
//  JSONDecorator.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Responsible for beautifying JSON
public class JSONDecorator {
    
    // Do not want the caller to directly initialize the object
    private init(json: String, style: HighlightStyle) {
        self.json = json
        self.style = style
    }
    
    /// The JSON string to be highlighted.
    private let json: String
    
    /// Style of highlight. See `HighlightStyle` for details.
    private let style: HighlightStyle
    
    /// JSON slice. See `JSONSlice` for details.
    public var slices: [JSONSlice] = []
    
    /// The string used to hold the icon of the expand button
    private lazy var expandIconString = createIconAttributedString(with: style.expandIcon)
    
    /// The string used to hold the icon of the fold button
    private lazy var foldIconString = createIconAttributedString(with: style.foldIcon)
    
    /// A newline string with the same style as JSON.
    /// Can be used to splice slices into a complete string.
    private(set) lazy var wrapString = NSAttributedString(string: "\n", attributes: createStyle(foregroundColor: nil))
    
    private lazy var startStyle = createStyle(foregroundColor: style.color.keyWord)
    private lazy var keyWordStyle = createStyle(foregroundColor: style.color.keyWord)
    private lazy var keyStyle = createStyle(foregroundColor: style.color.key)
    private lazy var linkStyle = createStyle(foregroundColor: style.color.link)
    private lazy var stringStyle = createStyle(foregroundColor: style.color.string)
    private lazy var numberStyle = createStyle(foregroundColor: style.color.number)
    private lazy var boolStyle = createStyle(foregroundColor: style.color.boolean)
    private lazy var nullStyle = createStyle(foregroundColor: style.color.null)
    
    private lazy var placeholderStyle = createStyle(
        foregroundColor: style.color.lineText,
        other: [.backgroundColor : style.color.lineBackground]
    )
    
    private lazy var unknownStyle = createStyle(
        foregroundColor: style.color.unknownText,
        other: [.backgroundColor : style.color.unknownBackground]
    )
}

public extension JSONDecorator {
    
    /// Highlight the incoming JSON string.
    ///
    /// Serve for `JSONPreview`. Will split JSON into arrays that meet the requirements of `JSONPreview` display.
    ///
    /// - Parameters:
    ///   - json: The JSON string to be highlighted.
    ///   - judgmentValid: Whether to check the validity of JSON.
    ///   - style: style of highlight. See `HighlightStyle` for details.
    /// - Returns: Return `nil` when JSON is invalid. See `JSONDecorator` for details.
    static func highlight(_ json: String, judgmentValid: Bool, style: HighlightStyle = .default) -> JSONDecorator? {
        
        if judgmentValid {
            
            guard let data = json.data(using: .utf8),
                let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
                return nil
            }
        }
        
        return highlight(json, style: style)
    }
    
    /// Highlight the incoming JSON string.
    ///
    /// Serve for `JSONPreview`. Will split JSON into arrays that meet the requirements of `JSONPreview` display.
    ///
    /// - Parameters:
    ///   - json: The JSON string to be highlighted.
    ///   - style: style of highlight. See `HighlightStyle` for details.
    /// - Returns: See `JSONDecorator` for details.
    static func highlight(_ json: String, style: HighlightStyle = .default) -> JSONDecorator {
        
        let decorator = JSONDecorator(json: json, style: style)
        
        decorator.slices = decorator._slices
        
        return decorator
    }
}

private extension JSONDecorator {
    
    var _slices: [JSONSlice] {
        
        var _slices: [JSONSlice] = []
        
        // Record indentation level
        var level = 0
        
        var lastToken: JSONLexer.Token? = nil
        
        JSONLexer.getTokens(of: json).forEach { (token) in
            
            defer { lastToken = token }
            
            let lineNumber = _slices.count + 1
            
            switch token {
            
            // MARK: objectBegin
            case .objectBegin:
                
                // There is a previous slice, and the previous slice is a colon.
                // Need to splice the current slice to the previous slice.
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let expandString = NSMutableAttributedString(
                        string: " {",
                        attributes: startStyle
                    )
                    
                    let foldString = NSMutableAttributedString(
                        string: "{Object...}",
                        attributes: placeholderStyle
                    )
                    
                    foldString.insert(NSAttributedString(string: " ", attributes: keyWordStyle), at: 0)
                    
                    expandString.insert(foldIconString, at: 0)
                    foldString.insert(expandIconString, at: 0)
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(expandString)
                    
                    let lastFolded = NSMutableAttributedString(attributedString: lastSlices.folded!)
                    lastFolded.append(foldString)
                    
                    _slices[_slices.count - 1].expand = lastExpand
                    _slices[_slices.count - 1].folded = lastFolded
                }
                
                // When the conditions are not met, create a new slice
                else {
                    
                    let indentation = createIndentedString(level: level)
                    
                    let expandString = NSMutableAttributedString(
                        string: indentation + " {",
                        attributes: startStyle
                    )
                    
                    let foldString = NSMutableAttributedString(
                        string: "{Object...}",
                        attributes: placeholderStyle
                    )
                    
                    foldString.insert(NSAttributedString(string: indentation, attributes: keyWordStyle), at: 0)
                    foldString.insert(NSAttributedString(string: " ", attributes: keyWordStyle), at: indentation.count)
                    
                    foldString.insert(expandIconString, at: indentation.count)
                    expandString.insert(foldIconString, at: indentation.count)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString, folded: foldString))
                }
                
                level += 1
                
            // MARK: objectEnd
            case .objectEnd:
                
                level -= 1
                
                let indentation = createIndentedString(level: level)
                
                let expandString = NSMutableAttributedString(
                    string: indentation + "}",
                    attributes: startStyle
                )
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString))
                
            // MARK: objectKey
            case .objectKey(let key):
                
                let indentation = createIndentedString(level: level)
                
                let expandString = NSAttributedString(
                    string: indentation + "\"\(key)\"",
                    attributes: keyStyle
                )
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString))
                
            // MARK: arrayBegin
            case .arrayBegin:
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let expandString = NSMutableAttributedString(
                        string: " [",
                        attributes: startStyle
                    )
                    
                    let foldString = NSMutableAttributedString(
                        string: "[Array...]",
                        attributes: placeholderStyle
                    )
                    
                    foldString.insert(NSAttributedString(string: " ", attributes: keyWordStyle), at: 0)
                    
                    foldString.insert(expandIconString, at: 0)
                    expandString.insert(foldIconString, at: 0)
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(expandString)
                    
                    let lastFolded = NSMutableAttributedString(attributedString: lastSlices.folded!)
                    lastFolded.append(foldString)
                    
                    _slices[_slices.count - 1].expand = lastExpand
                    _slices[_slices.count - 1].folded = lastFolded
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    
                    let expandString = NSMutableAttributedString(
                        string: indentation + " [",
                        attributes: startStyle
                    )
                    
                    let foldString = NSMutableAttributedString(
                        string: "[Array...]",
                        attributes: placeholderStyle
                    )
                    
                    foldString.insert(NSAttributedString(string: indentation, attributes: keyWordStyle), at: 0)
                    foldString.insert(NSAttributedString(string: " ", attributes: keyWordStyle), at: indentation.count)
                    
                    foldString.insert(expandIconString, at: indentation.count)
                    expandString.insert(foldIconString, at: indentation.count)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString, folded: foldString))
                }
                
                level += 1
                
            // MARK: arrayEnd
            case .arrayEnd:
                
                level -= 1
                
                let indentation = createIndentedString(level: level)
                
                let expandString = NSMutableAttributedString(
                    string: indentation + "]",
                    attributes: startStyle
                )
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString))
                
            // MARK: colon
            case .colon:
                
                guard let lastSlices = _slices.last else { break }
                
                let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                
                lastExpand.append(NSAttributedString(
                    string: " : ",
                    attributes: keyWordStyle
                ))
                
                _slices[_slices.count - 1].expand = lastExpand
                _slices[_slices.count - 1].folded = lastExpand
                
            // MARK: comma
            case .comma:
                
                guard let lastSlices = _slices.last else { break }
                
                let commaString = NSAttributedString(string: ",", attributes: keyWordStyle)
                
                let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                lastExpand.append(commaString)
                
                _slices[_slices.count - 1].expand = lastExpand
                
                // Add a comma to the beginning of the token
                guard lastToken == .objectEnd || lastToken == .arrayEnd else { break }
                
                for i in (0 ..< _slices.count).reversed() {
                    
                    let _slice = _slices[i]
                    
                    guard let _folded = _slice.folded, _slice.level == lastSlices.level else {
                        continue
                    }
                    
                    let lastFolded = NSMutableAttributedString(attributedString: _folded)
                    lastFolded.append(commaString)
                    _slices[i].folded = lastFolded
                    
                    break
                }
                
            // MARK: - Link
            case .link(let value):
                
                let addExtraLinkStyle: (NSMutableAttributedString, Int) -> Void = {
                    
                    let range = NSRange(location: $1, length: value.count)
                    
                    $0.addAttribute(.link, value: value, range: range)
                    $0.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                }
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    
                    let attString = NSMutableAttributedString(string: "\"\(value)\"", attributes: linkStyle)
                    
                    addExtraLinkStyle(attString, 1)
                    
                    lastExpand.append(attString)
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: nil
                    )
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    
                    let attString = NSMutableAttributedString(string: indentation + "\"\(value)\"", attributes: linkStyle)
                    
                    addExtraLinkStyle(attString, indentation.count + 1)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: attString))
                }
                
            // MARK: string
            case .string(let value):
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: "\"\(value)\"", attributes: stringStyle))
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: nil
                    )
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let string = NSAttributedString(string: indentation + "\"\(value)\"", attributes: stringStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: string))
                }
                
            // MARK: number
            case .number(let number):
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: "\(number)", attributes: numberStyle))
                    
                    _slices[_slices.count - 1].expand = lastExpand
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let numberString = NSAttributedString(string: indentation + "\(number)", attributes: numberStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: numberString))
                }
                
            // MARK: boolean
            case .boolean(let bool):
                
                let value = bool ? "true" : "false"
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: value, attributes: boolStyle))
                    
                    _slices[_slices.count - 1].expand = lastExpand
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let boolString = NSAttributedString(string: indentation + value, attributes: boolStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: boolString))
                }
                
            // MARK: null
            case .null:
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: "null", attributes: nullStyle))
                    
                    _slices[_slices.count - 1].expand = lastExpand
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let nullString = NSAttributedString(string: indentation + "null", attributes: nullStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: nullString))
                }
                
            // MARK: unknown
            case .unknown(let string):
                
                let newString = string.replacingOccurrences(of: "\n", with: "")
                
                let indentation = createIndentedString(level: level)
                
                let attributedString = NSMutableAttributedString(string: indentation)
                
                attributedString.append(NSAttributedString(string: newString, attributes: unknownStyle))
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: attributedString))
            }
        }
        
        return _slices
    }
}

// MARK: - Tools

private extension JSONDecorator {
    
    /// Create a string to represent indentation.
    ///
    /// - Parameter level: Current level.
    /// - Returns: Use the indentation indicated by `"\t"`.
    func createIndentedString(level: Int) -> String {
        return (0 ..< level).map{ _ in "\t" }.joined()
    }
    
    /// Create an `NSAttributedString` object for displaying image.
    ///
    /// - Parameter image: The image to be displayed.
    /// - Returns: `NSAttributedString` object.
    func createIconAttributedString(with image: UIImage) -> NSAttributedString {
        
        let expandAttach = NSTextAttachment()
        
        expandAttach.image = image
        
        let font = style.jsonFont
        
        let y = (style.lineHeight - font.lineHeight + 1) + font.descender
        
        expandAttach.bounds = CGRect(x: 0, y: y, width: font.ascender, height: font.ascender)
        
        return NSAttributedString(attachment: expandAttach)
    }
    
    func createStyle(
        foregroundColor: UIColor?,
        other: [NSAttributedString.Key : Any]? = nil
    ) -> [NSAttributedString.Key : Any] {
        
        var newStyle: [NSAttributedString.Key : Any] = [.font : style.jsonFont]
        
        if let color = foregroundColor {
            newStyle[.foregroundColor] = color
        }
        
        let lineHeightMultiple: CGFloat = 1
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.maximumLineHeight = style.lineHeight
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.lineSpacing = 0
        
        newStyle[.paragraphStyle] = paragraphStyle
        
        newStyle[.baselineOffset] = (style.lineHeight - style.jsonFont.lineHeight) + 1
        
        if let other = other {
            other.forEach { newStyle[$0] = $1 }
        }
        
        return newStyle
    }
}
