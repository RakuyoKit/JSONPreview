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
    
    
    
    private lazy var  keyWordStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.keyWord
    ]
    
    private lazy var  placeholderStyle: [NSAttributedString.Key : Any] = [
        .foregroundColor : style.color.lineText,
        .backgroundColor : style.color.lineBackground,
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
        
        // 1. Lexical analysis of JSON
        let tokens = JSONLexer.getTokens(of: json)
        
        // 2. Traverse, create the corresponding slice
        tokens.enumerated().forEach {
            
            lastToken = $1
            
            let indentation = createIndentedString(level: level)
            
            switch $1 {
            
            case .objectBegin:
                
                // 配置展开时显示的富文本内容
                let expandString = NSMutableAttributedString(
                    string: indentation + " {",
                    attributes: keyWordStyle
                )
                
                // 插入展开图标
                expandString.insert(expandIconString, at: indentation.count)
                
                // 配置折叠时显示的富文本内容
                let foldString = NSMutableAttributedString(
                    string: indentation + " {Object...}",
                    attributes: placeholderStyle
                )
                
                // 插入折叠图标
                foldString.insert(foldIconString, at: indentation.count)
                
                // 存在上一个节点，且上一个节点为冒号。
                // 需要将当前节点拼接到上一个节点上。
                if let lastToken = lastToken, case .colon = lastToken, let lastSlices = slices.last {
                    
                    let lastExpand = NSMutableAttributedString(attributedString: lastSlices.expand)
                    lastExpand.append(expandString)
                    
                    let lastFolded = NSMutableAttributedString(attributedString: lastSlices.folded!)
                    lastFolded.append(foldString)
                    
                    _slices[slices.count - 1] = JSONSlice(
                        level: lastSlices.level,
                        lineNumber: lastSlices.lineNumber,
                        expand: lastExpand,
                        folded: lastFolded
                    )
                }
                
                // 不满足条件时，创建新节点
                else {
                    _slices.append(JSONSlice(level: level, lineNumber: String($0 + 1), expand: expandString, folded: foldString))
                }
                
                level += 1
                
            case .objectEnd:
                break
                
            case .objectKey(let key):
                
                
                
                break
                
            case .arrayBegin:
                break
                
            case .arrayEnd:
                break
                
            case .colon:
                break
                
            case .comma:
                break
                
            case .string(_):
                break
                
            case .number(_):
                break
                
            case .boolean(_):
                break
                
            case .null:
                break
                
            case .unknown(_):
                break
                
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
    /// - Parameters:
    ///   - image: The image to be displayed.
    ///   - size: The size of the picture to be displayed. Default is `18`.
    /// - Returns: `NSAttributedString` object.
    func createIconAttributedString(with image: UIImage, size: CGFloat = 18) -> NSAttributedString {
        
        let expandAttach = NSTextAttachment()
        
        expandAttach.image = image
        expandAttach.bounds = CGRect(x: 0, y: 0, width: 18, height: 18)
        
        return NSAttributedString(attachment: expandAttach)
    }
}
