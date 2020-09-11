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
    
    private init() {
        // Do not want the caller to directly initialize the object
    }
    
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
        
        var slices: [JSONSlice] = []
        
        // 1. Lexical analysis of JSON
        let tokens = JSONLexer.getTokens(of: json)
        
        
        
        print(tokens)
        
        
        
        
        
        
//        // Record indentation level
//        var level = 0
//
//        let keyWordStyle: [NSAttributedString.Key : Any] = [
//            .foregroundColor : style.color.keyWord
//        ]
//
//        let placeholderStyle: [NSAttributedString.Key : Any] = [
//            .foregroundColor : style.color.lineText,
//            .backgroundColor : style.color.lineBackground,
//        ]
//
//        let expandIconString = createIconAttributedString(with: style.expandIcon)
//        let foldIconString = createIconAttributedString(with: style.foldIcon)
//
////        let commaString = NSAttributedString(string: ",", attributes: keyWordStyle)
////
////        // 上一个可以被折叠的节点在 `slices` 中的索引
////        var lastFoldIndex: Int? = nil
//
//        json.enumerated().forEach {
//
//            switch $0.element {
//
//                // Object 的开头
//            case "{":
//
//                // 计算当前层级
//                let indentation = calculateIndent(level: level)
//
//                // 配置展开时显示的富文本内容
//                let expandString = NSMutableAttributedString(
//                    string: indentation + "{",
//                    attributes: keyWordStyle
//                )
//
//                // 插入展开图标
//                expandString.insert(expandIconString, at: indentation.count)
//
//                // 配置折叠时显示的富文本内容
//                let foldString = NSMutableAttributedString(
//                    string: indentation + "{Object...}",
//                    attributes: placeholderStyle
//                )
//
//                // 插入折叠图标
//                expandString.insert(foldIconString, at: indentation.count)
//
//                slices.append(JSONSlice(level: level, lineNumber: $0.offset + 1, expand: expandString, folded: foldString))
//
//                level += 1
//
//                // Object 的结尾
//            case "}":
//
//                level -= 1
//
//            default: break
//            }
//        }
        
        return slices
    }
}

// MARK: - Tools

private extension JSONDecorator {
    
    /// Calculate the indent.
    ///
    /// - Parameter level: Current level.
    /// - Returns: Use the indentation indicated by `"\t"`.
    static func calculateIndent(level: Int) -> String {
        return (0 ..< level).map{ _ in "\t" }.joined()
    }
    
    /// Create an `NSAttributedString` object for displaying image.
    ///
    /// - Parameters:
    ///   - image: The image to be displayed.
    ///   - size: The size of the picture to be displayed. Default is `18`.
    /// - Returns: `NSAttributedString` object.
    static func createIconAttributedString(with image: UIImage, size: CGFloat = 18) -> NSAttributedString {
        
        let expandAttach = NSTextAttachment()
        
        expandAttach.image = image
        expandAttach.bounds = CGRect(x: 0, y: 0, width: 18, height: 18)
        
        return NSAttributedString(attachment: expandAttach)
    }
}
