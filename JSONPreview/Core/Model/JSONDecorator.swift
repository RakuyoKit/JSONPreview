//
//  JSONDecorator.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Responsible for beautifying JSON
public final class JSONDecorator {
    /// Initialization method
    ///
    /// - Parameters:
    ///   - style: Style of highlight. See `HighlightStyle` for details.
    ///   - initialState: The initial state of the rendering result.
    public init(style: HighlightStyle, initialState: JSONSlice.State) {
        self.style = style
        self.initialState = initialState
    }
    
    /// Style of highlight. See `HighlightStyle` for details.
    public let style: HighlightStyle
    
    /// The initial state of the rendering result.
    ///
    /// All nodes with a folding effect have an initial state consistent with this value.
    public let initialState: JSONSlice.State
    
    /// JSON slice.
    ///
    /// See the `JSONSlice` and `createSlices(from:)` method for details.
    public internal(set) var slices: [JSONSlice] = []
    
    /// Current number of indent
    private var indent = 0
    
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
    ///   - style: style of highlight. See `HighlightStyle` for details.
    ///   - initialState: The initial state of the rendering result. All nodes with a folding effect have an initial state consistent with this value.
    ///   - judgmentValid: Whether to check the validity of JSON.
    /// - Returns: Return `nil` when JSON is invalid. See `JSONDecorator` for details.
    static func highlight(
        _ json: String,
        style: HighlightStyle = .`default`,
        initialState: JSONSlice.State = .`default`,
        judgmentValid: Bool = false
    ) -> JSONDecorator? {
        guard let data = json.data(using: .utf8) else { return nil }
        
        if judgmentValid,
           (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) == nil {
            return nil
        }
        
        let decorator = JSONDecorator(style: style, initialState: initialState)
        decorator.slices = decorator.createSlices(from: data)
        return decorator
    }
    
    /// Create json slice.
    ///
    /// Although you can initialize the `JSONDecorator` object directly,
    /// we still don't want you to assign the `slices` property directly
    /// because the internal logic of the JSONPreview is still incomplete and doesn't handle many situations.
    ///
    /// - Parameter json: The JSON string to be highlighted.
    /// - Returns: json slice. Returns an empty array in case of a json error.
    func createSlices(from json: String) -> [JSONSlice] {
        guard let data = json.data(using: .utf8) else { return [] }
        return createSlices(from: data)
    }
}

// MARK: - Main Logic

private extension JSONDecorator {
    func createSlices(from data: Data) -> [JSONSlice] {
        guard let jsonValue = createJSONValue(from: data) else { return [] }
        return processJSONValueRecursively(
            jsonValue,
            currentSlicesCount: 0,
            isNeedIndent: false,
            isNeedComma: false,
            foldedTimes: 0)
    }
    
    func createJSONValue(from data: Data) -> JSONValue? {
        return try? data.withUnsafeBytes {
            // we got utf8... happy path
            var parser = JSONParser(bytes: Array($0[0 ..< $0.count]))
            return try parser.parse()
        }
    }
    
    func processJSONValueRecursively(
        _ jsonValue: JSONValue,
        currentSlicesCount: Int,
        isNeedIndent: Bool,
        isNeedComma: Bool,
        foldedTimes: Int
    ) -> [JSONSlice] {
        var result: [JSONSlice] = []
        
        /// Simplify the initialization of `JSONSlice`
        func _append(expand: AttributedString, fold: AttributedString?, foldedTimes times: Int) {
            // `initialState` is only valid for nodes with a folding effect.
            let state = fold != nil ? initialState : .`default`
            
            let slice = JSONSlice(
                level: indent,
                lineNumber: currentSlicesCount + result.count + 1,
                state: state,
                expand: expand,
                folded: fold,
                foldedTimes: times)
            
            result.append(slice)
        }
        
        func createUnknownAttributedString(with string: String) -> AttributedString {
            let newString = string.replacingOccurrences(of: "\n", with: "")
            return .init(string: newString, attributes: unknownStyle)
        }
        
        func calculateSubSlicesFoldedTimes(currentState: JSONSlice.State) -> Int {
            switch currentState {
            case .expand: return 0
            case .folded: return foldedTimes + 1
            }
        }
        
        // Process each json value
        switch jsonValue {
        // MARK: array
        case .array(let values):
            let subSlicesFoldedTimes = calculateSubSlicesFoldedTimes(currentState: initialState)
            
            let (startExpand, startFold) = createArrayStartAttribute(
                isNeedIndent: isNeedIndent,
                isNeedComma: isNeedComma)
            
            _append(expand: startExpand, fold: startFold, foldedTimes: foldedTimes)
            
            func _appendArrayEnd() {
                let endExpand = createArrayEndAttribute(isNeedComma: isNeedComma)
                _append(expand: endExpand, fold: nil, foldedTimes: subSlicesFoldedTimes)
            }
            
            guard !values.isEmpty else {
                // If the array is empty, add the end flag directly.
                _appendArrayEnd()
                return result
            }
            
            incIndent()
            
            // Process each value
            for (i, value) in values.enumerated() {
                let _isNeedComma = i != (values.count - 1)
                
                let slices = processJSONValueRecursively(
                    value,
                    currentSlicesCount: currentSlicesCount + result.count,
                    isNeedIndent: true,
                    isNeedComma: _isNeedComma, 
                    foldedTimes: subSlicesFoldedTimes)
                result.append(contentsOf: slices)
            }
            
            decIndent()
            
            // The end node is added only if the array is correct.
            if case .wrong = values.last?.isRight { } else {
                _appendArrayEnd()
            }
            
            return result
            
        // MARK: object
        case .object(let object):
            let subSlicesFoldedTimes = calculateSubSlicesFoldedTimes(currentState: initialState)
            
            let (startExpand, startFold) = createObjectStartAttribute(
                isNeedIndent: isNeedIndent,
                isNeedComma: isNeedComma)
            
            _append(expand: startExpand, fold: startFold, foldedTimes: foldedTimes)
            
            func _appendObjectEnd() {
                let endExpand = createObjectEndAttribute(isNeedComma: isNeedComma)
                _append(expand: endExpand, fold: nil, foldedTimes: subSlicesFoldedTimes)
            }
            
            guard !object.isEmpty else {
                // If the object is empty, add the end flag directly.
                _appendObjectEnd()
                return result
            }
            
            // Sorting the key.
            // The order of displaying each time the bail is taken is consistent.
            let sortKeys = object.rankingUnknownKeyLast()
            
            incIndent()
            
            // Process each value
            for (i, key) in sortKeys.enumerated() {
                guard let value = object[key] else { continue }
                
                func createKeyAttribute(_ key: String, isNeedColon: Bool = true) -> AttributedString {
                    let keyAttribute = AttributedString(string: key, attributes: keyStyle)
                    if isNeedColon {
                        keyAttribute.append(colonAttributeString)
                    }
                    return keyAttribute
                }
                
                // Different treatment according to different situations
                switch value.isRight {
                case .wrong:
                    let slices = processJSONValueRecursively(
                        value,
                        currentSlicesCount: currentSlicesCount + result.count,
                        isNeedIndent: true,
                        isNeedComma: false,
                        foldedTimes: subSlicesFoldedTimes)
                    
                    if key.isWrong {
                        result.append(contentsOf: slices)
                        
                    } else {
                        let string = writeIndent() + "\"\(key.key)\""
                        let expand = createKeyAttribute(string, isNeedColon: false)
                        
                        if let slice = slices.first {
                            expand.append(slice.expand)
                        }
                        
                        _append(expand: expand, fold: nil, foldedTimes: subSlicesFoldedTimes)
                    }
                    
                case .right(let isContainer):
                    let string = writeIndent() + "\"\(key.key)\""
                    
                    let _isNeedComma = (i != (object.count - 1)) && {
                        guard sortKeys.indices.contains(i + 1) else { return false }
                        switch object[sortKeys[i + 1]]?.isRight {
                        case .right: return true
                        default: return false
                        }
                    }()
                    
                    let expand = createKeyAttribute(string)
                    
                    if isContainer {
                        let fold = createKeyAttribute(string)
                        
                        // Get the content of the subvalue
                        var slices = processJSONValueRecursively(
                            value,
                            currentSlicesCount: currentSlicesCount + result.count,
                            isNeedIndent: false,
                            isNeedComma: _isNeedComma,
                            foldedTimes: subSlicesFoldedTimes)
                        
                        if !slices.isEmpty {
                            let startSlice = slices.removeFirst()
                            expand.append(startSlice.expand)
                            
                            if let valueFold = startSlice.folded {
                                fold.append(valueFold)
                            }
                            
                            _append(expand: expand, fold: fold, foldedTimes: subSlicesFoldedTimes)
                        }
                        
                        result.append(contentsOf: slices)
                        
                    } else {
                        var fold: AttributedString? = nil
                        
                        // Get the content of the subvalue
                        let slices = processJSONValueRecursively(
                            value,
                            currentSlicesCount: 0,
                            isNeedIndent: false,
                            isNeedComma: _isNeedComma,
                            foldedTimes: subSlicesFoldedTimes)
                        
                        // Usually there is only one value for `slices` in this case,
                        // so only the first value is taken
                        if let slice = slices.first {
                            expand.append(slice.expand)
                            
                            if let valueFold = slice.folded {
                                fold = createKeyAttribute(string)
                                fold?.append(valueFold)
                            }
                            
                            _append(expand: expand, fold: fold, foldedTimes: subSlicesFoldedTimes)
                        }
                    }
                }
            }
            
            decIndent()
            
            // The end node is added only if the object is correct.
            if let lastKey = sortKeys.last,
               case .wrong = object[lastKey]?.isRight { }
            else {
                _appendObjectEnd()
            }
            
            return result
            
        case let .string(value, wrong):
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
            
            if let wrong = wrong {
                expand.append(createUnknownAttributedString(with: wrong))
            }
            
            _append(expand: expand, fold: nil, foldedTimes: foldedTimes)
            return result
            
        // MARK: number
        case let .number(value, wrong):
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + "\(value)"
            let expand = AttributedString(string: string, attributes: numberStyle)
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            if let wrong = wrong {
                expand.append(createUnknownAttributedString(with: wrong))
            }
            
            _append(expand: expand, fold: nil, foldedTimes: foldedTimes)
            return result
            
        // MARK: bool
        case let .bool(value, wrong):
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + (value ? "true" : "false")
            let expand = AttributedString(string: string, attributes: boolStyle)
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            if let wrong = wrong {
                expand.append(createUnknownAttributedString(with: wrong))
            }
            
            _append(expand: expand, fold: nil, foldedTimes: foldedTimes)
            return result
            
        // MARK: null
        case .null(let wrong):
            let indent = isNeedIndent ? writeIndent() : ""
            let string = indent + "null"
            let expand = AttributedString(string: string, attributes: nullStyle)
            
            if isNeedComma {
                expand.append(commaAttributeString)
            }
            
            if let wrong = wrong {
                expand.append(createUnknownAttributedString(with: wrong))
            }
            
            _append(expand: expand, fold: nil, foldedTimes: foldedTimes)
            return result
            
        // MARK: unknown
        case .unknown(let string):
            let indent = isNeedIndent ? writeIndent() : ""
            
            let expand = AttributedString(string: indent)
            expand.append(createUnknownAttributedString(with: string))
            
            _append(expand: expand, fold: nil, foldedTimes: foldedTimes)
            return result
        }
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
    ///   - isNeedIndent: Indentation required.
    ///   - isNeedComma: Comma required.
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
    ///   - isNeedComma: Comma required.
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
