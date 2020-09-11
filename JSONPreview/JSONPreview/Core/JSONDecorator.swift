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
    
    /// The string used to hold the icon of the expand button
    private lazy var expandIconString = createIconAttributedString(with: style.expandIcon)
    
    /// The string used to hold the icon of the fold button
    private lazy var foldIconString = createIconAttributedString(with: style.foldIcon)
    
    private lazy var startStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.keyWord
    ]
    
    private lazy var keyWordStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.keyWord
    ]
    
    private lazy var placeholderStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.lineText,
        .backgroundColor : style.color.lineBackground,
    ]
    
    private lazy var keyStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.key
    ]
    
    private lazy var stringStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.string
    ]
    
    private lazy var numberStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.number
    ]
    
    private lazy var boolStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.boolean
    ]
    
    private lazy var nullStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.null
    ]
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
    /// - Returns: Return `nil` when JSON is invalid, otherwise return `[JSONSlice]`. See `JSONSlice` for details.
    static func highlight(_ json: String, judgmentValid: Bool, style: HighlightStyle = .default) -> [JSONSlice]? {
        
        guard let data = json.data(using: .utf8),
            let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            
            return nil
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
    /// - Returns: See `JSONSlice` for details.
    static func highlight(_ json: String, style: HighlightStyle = .default) -> [JSONSlice] {
        return JSONDecorator(json: json, style: style).slices
    }
}

private extension JSONDecorator {
    
    var slices: [JSONSlice] {
        
        var _slices: [JSONSlice] = []
        
        // Record indentation level
        var level = 0
        
        var lastToken: JSONLexer.Token? = nil
        
        JSONLexer.getTokens(of: json).forEach {
            
            let lineNumber = String(_slices.count + 1)
            
            switch $0 {
            
            case .objectBegin:
                
                let indentation = createIndentedString(level: level)
                
                // 配置折叠时显示的富文本内容
                let foldString = NSMutableAttributedString(
                    string: indentation + " {Object...}",
                    attributes: placeholderStyle
                )
                
                // 插入折叠图标
                foldString.insert(foldIconString, at: indentation.count)
                
                // 存在上一个节点，且上一个节点为冒号。
                // 需要将当前节点拼接到上一个节点上。
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    // 配置展开时显示的富文本内容
                    let expandString = NSMutableAttributedString(
                        string: " {",
                        attributes: startStyle
                    )
                    
                    // 插入展开图标
                    expandString.insert(expandIconString, at: 0)
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(expandString)
                    
                    let lastFolded = NSMutableAttributedString(attributedString: lastSlices.folded!)
                    lastFolded.append(foldString)
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: lastFolded
                    )
                }
                
                // 不满足条件时，创建新节点
                else {
                    
                    // 配置展开时显示的富文本内容
                    let expandString = NSMutableAttributedString(
                        string: indentation + " {",
                        attributes: startStyle
                    )
                    
                    // 插入展开图标
                    expandString.insert(expandIconString, at: indentation.count)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString, folded: foldString))
                }
                
                level += 1
                
            case .objectEnd:
                
                level -= 1
                
                let indentation = createIndentedString(level: level)
                
                let expandString = NSMutableAttributedString(
                    string: indentation + "}",
                    attributes: startStyle
                )
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString))
                
            case .objectKey(let key):
                
                let indentation = createIndentedString(level: level)
                
                let expandString = NSAttributedString(
                    string: indentation + "\"\(key)\"",
                    attributes: keyStyle
                )
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString))
                
            case .arrayBegin:
                
                let indentation = createIndentedString(level: level)
                
                // 配置折叠时显示的富文本内容
                let foldString = NSMutableAttributedString(
                    string: indentation + " [Array...]",
                    attributes: placeholderStyle
                )
                
                // 插入折叠图标
                foldString.insert(foldIconString, at: indentation.count)
                
                // 存在上一个节点，且上一个节点为冒号。
                // 需要将当前节点拼接到上一个节点上。
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    // 配置展开时显示的富文本内容
                    let expandString = NSMutableAttributedString(
                        string: " [",
                        attributes: startStyle
                    )
                    
                    // 插入展开图标
                    expandString.insert(expandIconString, at: 0)
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(expandString)
                    
                    let lastFolded = NSMutableAttributedString(attributedString: lastSlices.folded!)
                    lastFolded.append(foldString)
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: lastFolded
                    )
                }
                
                // 不满足条件时，创建新节点
                else {
                    
                    let expandString = NSMutableAttributedString(
                        string: indentation + " [",
                        attributes: startStyle
                    )
                    
                    expandString.insert(expandIconString, at: indentation.count)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString, folded: foldString))
                }
                
                level += 1
                
            case .arrayEnd:
                
                level -= 1
                
                let indentation = createIndentedString(level: level)
                
                let expandString = NSMutableAttributedString(
                    string: indentation + "]",
                    attributes: startStyle
                )
                
                _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: expandString))
                
            case .colon:
                
                guard let lastSlices = _slices.last else { break }
                
                let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                
                lastExpand.append(NSAttributedString(
                    string: " : ",
                    attributes: keyWordStyle
                ))
                
                _slices[_slices.count - 1] = JSONSlice(
                    level: lastSlices.level,
                    lineNumber: lastSlices.lineNumber,
                    expand: lastExpand,
                    folded: lastExpand
                )
                
            case .comma:
                
                guard let lastSlices = _slices.last else { break }
                
                let commaString = NSAttributedString(string: ",", attributes: keyWordStyle)
                
                let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                lastExpand.append(commaString)
                
                var lastFolded: NSMutableAttributedString? = nil
                
                if let _folded = lastSlices.folded {
                    lastFolded = NSMutableAttributedString(attributedString: _folded)
                    lastFolded?.append(commaString)
                }
                
                _slices[_slices.count - 1] = JSONSlice(
                    level: lastSlices.level,
                    lineNumber: lastSlices.lineNumber,
                    expand: lastExpand,
                    folded: lastFolded
                )
                
            case .string(let value):
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: value, attributes: stringStyle))
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: nil
                    )
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let string = NSAttributedString(string: indentation + value, attributes: stringStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: string))
                }
                
            case .number(let number):
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: "\(number)", attributes: numberStyle))
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: nil
                    )
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let numberString = NSAttributedString(string: indentation + "\(number)", attributes: numberStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: numberString))
                }
                
            case .boolean(let bool):
                
                let value = bool ? "true" : "false"
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: value, attributes: boolStyle))
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: nil
                    )
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let boolString = NSAttributedString(string: indentation + value, attributes: boolStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: boolString))
                }
                
            case .null:
                
                if let _lastToken = lastToken, case .colon = _lastToken, let lastSlices = _slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(NSAttributedString(string: "null", attributes: nullStyle))
                    
                    _slices[_slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: nil
                    )
                    
                } else {
                    
                    let indentation = createIndentedString(level: level)
                    let nullString = NSAttributedString(string: indentation + "null", attributes: nullStyle)
                    
                    _slices.append(JSONSlice(level: level, lineNumber: lineNumber, expand: nullString))
                }
                
            case .unknown(_):
                break
            }
            
            lastToken = $0
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
    /// - Parameters:
    ///   - image: The image to be displayed.
    ///   - size: The size of the picture to be displayed. Default is `18`.
    /// - Returns: `NSAttributedString` object.
    func createIconAttributedString(with image: UIImage, size: CGFloat = 18) -> NSAttributedString {
        
        let expandAttach = NSTextAttachment()
        
        expandAttach.image = image
        expandAttach.bounds = CGRect(x: 0, y: -4.5, width: 20, height: 20)
        
        return NSAttributedString(attachment: expandAttach)
    }
}
