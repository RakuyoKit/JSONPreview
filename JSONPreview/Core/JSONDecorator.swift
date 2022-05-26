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
    private init(style: HighlightStyle) {
        self.style = style
    }
    
    /// Style of highlight. See `HighlightStyle` for details.
    private let style: HighlightStyle
    
    /// Current number of indent
    private var indent = 0
    
    /// JSON slice. See `JSONSlice` for details.
    public var slices: [JSONSlice] = []
    
    // MARK: - Style
    
    /// The string used to hold the icon of the expand button
    private lazy var expandIconString = createIconAttributedString(with: style.expandIcon)
    
    /// The string used to hold the icon of the fold button
    private lazy var foldIconString = createIconAttributedString(with: style.foldIcon)
    
    /// A newline string with the same style as JSON.
    /// Can be used to splice slices into a complete string.
    private(set) lazy var wrapString = AttributedString(string: "\n", attributes: createStyle(foregroundColor: nil))
    
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

// MARK: - Public

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
    static func highlight(
        _ json: String,
        judgmentValid: Bool = false,
        style: HighlightStyle = .default
    ) -> JSONDecorator? {
        guard let data = json.data(using: .utf8) else { return nil }
        
        if judgmentValid {
            guard let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
                return nil
            }
        }
        
        let decorator = JSONDecorator(style: style)
        decorator.slices = decorator.createSlices(from: data)
        return decorator
    }
}

// MARK: - Main Logic

private extension JSONDecorator {
    func createSlices(from data: Data) -> [JSONSlice] {
        guard let jsonValue = createJSONValue(from: data) else { return [] }
        return createJSONSlices(from: jsonValue)
    }
    
    func createJSONValue(from data: Data) -> JSONValue? {
        return try? data.withUnsafeBytes {
            // we got utf8... happy path
            var parser = JSONParser(bytes: Array($0[0 ..< $0.count]))
            return try parser.parse()
        }
    }
    
    func createJSONSlices(from jsonValue: JSONValue) -> [JSONSlice] {
        return processJSONValueRecursively(jsonValue, isNeedIndent: false, isNeedComma: false)
    }
    
    func processJSONValueRecursively(
        _ jsonValue: JSONValue,
        isNeedIndent: Bool,
        isNeedComma: Bool
    ) -> [JSONSlice] {
        var result: [JSONSlice] = []
        
        // 简化 JSONSlice 的初始化
        func _append(expand: AttributedString, fold: AttributedString?) {
            let slice = JSONSlice(level: indent, lineNumber: result.count + 1, expand: expand, folded: fold)
            result.append(slice)
        }
        
        // 处理每个 json 节点
        switch jsonValue {
        // MARK: array
        case .array(let values):
            // 处理开头节点
            let (startExpand, startFold) = createArrayStartAttribute(
                isNeedIndent: isNeedIndent,
                isNeedComma: isNeedComma)
            
            // 将开头节点添加到结果数组中
            _append(expand: startExpand, fold: startFold)
            
            if !values.isEmpty {
                // 增加缩进
                incIndent()
                
                // 处理里面每一个 value
                for (i, value) in values.enumerated() {
                    let _isNeedComma = i != (values.count - 1)
                    
                    let slices = processJSONValueRecursively(value, isNeedIndent: true, isNeedComma: _isNeedComma)
                    result.append(contentsOf: slices)
                }
                
                // 减少缩进
                decIndent()
            }
            
            // 处理结束节点
            let endExpand = createArrayEndAttribute(isNeedComma: isNeedComma)
            
            // 将结尾节点添加到结果数组中
            _append(expand: endExpand, fold: nil)
            
        // MARK: object
        case .object(let object):
            // 处理开头节点
            let (startExpand, startFold) = createObjectStartAttribute(
                isNeedIndent: isNeedIndent,
                isNeedComma: isNeedComma)
            
            // 将开头节点添加到结果数组中
            _append(expand: startExpand, fold: startFold)
            
            if !object.isEmpty {
                // 增加缩进
                incIndent()
                
                // 处理里面每一个 value
                for (i, (key, value)) in object.enumerated() {
                    let _isNeedComma = i != (object.count - 1)
                    let string = writeIndent() + "\"\(key)\""
                    
                    let createKeyAttribute: () -> AttributedString = { [weak self] in
                        guard let this = self else { return .init(string: "") }
                        
                        let keyAttribute = AttributedString(string: string, attributes: this.keyStyle)
                        keyAttribute.append(this.colonAttributeString)
                        return keyAttribute
                    }
                    
                    let expand = createKeyAttribute()
                    
                    // 根据不同的情况进行不同的处理
                    if value.isContainer {
                        let fold = createKeyAttribute()
                        
                        // 获取子值的内容
                        var slices = processJSONValueRecursively(value, isNeedIndent: false, isNeedComma: _isNeedComma)
                        
                        if !slices.isEmpty {
                            let startSlice = slices.removeFirst()
                            expand.append(startSlice.expand)
                            
                            if let valueFold = startSlice.folded {
                                fold.append(valueFold)
                            }
                            
                            _append(expand: expand, fold: fold)
                        }
                        
                        result.append(contentsOf: slices)
                        
                    } else {
                        var fold: AttributedString? = nil
                        
                        // 获取子值的内容
                        let slices = processJSONValueRecursively(value, isNeedIndent: false, isNeedComma: _isNeedComma)
                        
                        // 一般这种时候`slices`只会有一个值，所以只取第一个值
                        if let slice = slices.first {
                            expand.append(slice.expand)
                            
                            if let valueFold = slice.folded {
                                fold = createKeyAttribute()
                                fold?.append(valueFold)
                            }
                            
                            _append(expand: expand, fold: fold)
                        }
                    }
                }
                
                // 减少缩进
                decIndent()
            }
            
            // 处理结束节点
            let endExpand = createObjectEndAttribute(isNeedComma: isNeedComma)
            
            // 将结尾节点添加到结果数组中
            _append(expand: endExpand, fold: nil)
            
        case .string(let value):
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + "\"\(value)\""
            
            let expand: AttributedString
            
            if let url = value.validURL {
                // MARK: link
                expand = AttributedString(string: string, attributes: linkStyle)
                
                let urlString = url.urlString
                let range = NSRange(location: indent.count + 1, length: urlString.count)
                
                expand.addAttribute(.link, value: urlString, range: range)
                expand.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            } else {
                
                // MARK: string
                expand = AttributedString(string: string, attributes: stringStyle)
            }
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            _append(expand: expand, fold: nil)
            
        // MARK: number
        case .number(let value):
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + "\(value)"
            let expand = AttributedString(string: string, attributes: numberStyle)
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            _append(expand: expand, fold: nil)
            
        // MARK: bool
        case .bool(let value):
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + (value ? "true" : "false")
            let expand = AttributedString(string: string, attributes: boolStyle)
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            _append(expand: expand, fold: nil)
            
        // MARK: null
        case .null:
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + "null"
            let expand = AttributedString(string: string, attributes: nullStyle)
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            _append(expand: expand, fold: nil)
        }
        
        return result
    }
}

// MARK: - Indent

private extension JSONDecorator {
    /// Fixed value of the number of contractions per increase or decrease
    static let indentAmount = 1
    
    func incIndent() {
        indent += Self.indentAmount
    }
    
    func decIndent() {
        indent -= Self.indentAmount
    }
    
    func writeIndent() -> String {
        return (0 ..< indent).map { _ in "\t" }.joined()
    }
}

// MARK: - Attributed String

private extension JSONDecorator {
    
    /// An attribute string of ":"
    var colonAttributeString: AttributedString {
        createKeywordAttribute(key: " : ")
    }
    
    /// An attribute string of ","
    var commaAttributeString: AttributedString {
        createKeywordAttribute(key: ",")
    }
    
    /// Create an attribute string of "array - start node"
    func createArrayStartAttribute(isNeedIndent: Bool, isNeedComma: Bool) -> (AttributedString, AttributedString) {
        return createStartAttribute(expand: "[", fold: "[Array...]", isNeedIndent: isNeedIndent, isNeedComma: isNeedComma)
    }
    
    /// Create an attribute string of "Array - End Node"
    func createArrayEndAttribute(isNeedComma: Bool) -> AttributedString {
        return createEndAttribute(key: "]", isNeedComma: isNeedComma)
    }
    
    /// Create an attribute string of "Object - Start Node"
    func createObjectStartAttribute(isNeedIndent: Bool, isNeedComma: Bool) -> (AttributedString, AttributedString) {
        return createStartAttribute(expand: "{", fold: "{Object...}", isNeedIndent: isNeedIndent, isNeedComma: isNeedComma)
    }
    
    /// Create an attribute string of "object - end node"
    func createObjectEndAttribute(isNeedComma: Bool) -> AttributedString {
        return createEndAttribute(key: "}", isNeedComma: isNeedComma)
    }
    
    /// Create an attribute string of "keyword".
    ///
    /// - Parameter key: keyword
    /// - Returns: `AttributedString` object.
    func createKeywordAttribute(key: String) -> AttributedString {
        return .init(string: key, attributes: keyWordStyle)
    }
    
    /// Create an attribute string of "begin node".
    ///
    /// - Parameters:
    ///   - expand: String when expand.
    ///   - fold: String when folded.
    ///   - isNeedIndent:
    ///   - isNeedComma: Did need to append a comma at the end.
    /// - Returns: `AttributedString` object.
    func createStartAttribute(
        expand: String,
        fold: String,
        isNeedIndent: Bool,
        isNeedComma: Bool
    ) -> (AttributedString, AttributedString) {
        let indent = isNeedIndent ? writeIndent() : ""
        
        let expandString = AttributedString(
            string: indent + " " + expand,
            attributes: startStyle
        )
        
        let foldString = AttributedString(
            string: fold + (isNeedComma ? "," : ""),
            attributes: placeholderStyle
        )
        
        foldString.insert(createKeywordAttribute(key: indent + " "), at: 0)
        
        expandString.insert(foldIconString, at: indent.count)
        foldString.insert(expandIconString, at: indent.count)
        
        return (expandString, foldString)
    }
    
    /// Create an attribute string of "end node".
    ///
    /// - Parameters:
    ///   - key: Node characters, such as `}` or `]`.
    ///   - isNeedComma: Did need to append a comma at the end.
    /// - Returns: `AttributedString` object.
    func createEndAttribute(key: String, isNeedComma: Bool) -> AttributedString {
        let indent = writeIndent()
        let string = key + (isNeedComma ? "," : "")
        return .init(string: indent + string, attributes: startStyle)
    }
    
    /// Create an `AttributedString` object for displaying image.
    ///
    /// - Parameter image: The image to be displayed.
    /// - Returns: `AttributedString` object.
    func createIconAttributedString(with image: UIImage) -> AttributedString {
        let expandAttach = NSTextAttachment()
        expandAttach.image = image
        
        let font = style.jsonFont
        
        let y = (style.lineHeight - font.lineHeight + 1) + font.descender
        
        expandAttach.bounds = CGRect(x: 0, y: y, width: font.ascender, height: font.ascender)
        
        return .init(attachment: expandAttach)
    }
    
    func createStyle(foregroundColor: UIColor?, other: StyleInfos? = nil) -> StyleInfos {
        var newStyle: StyleInfos = [.font : style.jsonFont]
        
        if let color = foregroundColor {
            newStyle[.foregroundColor] = color
        }
        
        let lineHeightMultiple: CGFloat = 1
        let paragraphStyle = NSMutableParagraphStyle()
        
        if #available(iOS 15.0, *) {
            paragraphStyle.usesDefaultHyphenation = false
        }
        
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
