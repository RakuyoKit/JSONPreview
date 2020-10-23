//
//  JSONLexer.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/11.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// JSON lexical analyzer
public class JSONLexer {
    
    private init() {
        // Do not want the caller to directly initialize the object
    }
    
    private lazy var tokens: [Token] = []
    
    /// Storage hierarchy, used to analyze the type of data structure of the current token, and used for syntax analysis
    private lazy var beginNodes: [BeginNode] = []
}

extension JSONLexer {
    
    public enum Token: Equatable {
        
        case objectBegin // {
        
        case objectEnd // }
        
        case objectKey(String)
        
        case arrayBegin // [
        
        case arrayEnd // ]
        
        case colon // :
        
        case comma // ,
        
        case link(String)
        
        case string(String)
        
        case number(String)
        
        case boolean(Bool) // true or false
        
        case null
        
        case unknown(String)
    }

    fileprivate enum BeginNode: Equatable {
        
        case object // {
        
        case array // [
    }
}

public extension JSONLexer {
    
    /// Parse JSON string into `JSONLexer.Token` array.
    ///
    /// When `json` meets the following conditions, an empty array will be returned:
    ///
    /// 1. `json` is empty.
    ///
    /// - Parameter json: JSON to be processed.
    /// - Returns: Parsed Token array. See `JSONLexer.Token` for details.
    static func getTokens(of json: String) -> [Token] {
        
        guard !json.isEmpty else { return [] }
        
        let lexer = JSONLexer()
        
        var _json = json
        
        // Processing initial data
        switch _json.removeFirst() {
            
        case "{":
            lexer.beginNodes.append(.object)
            lexer.tokens.append(.objectBegin)
            
        case "[":
            lexer.beginNodes.append(.array)
            lexer.tokens.append(.arrayBegin)
            
        default:
            lexer.tokens.append(.unknown(json))
            return lexer.tokens
        }
        
        // Parse the remaining content
        lexer.getremainingTokens(in: _json)
        
        return lexer.tokens
    }
}

private extension JSONLexer {
    
    /// Get the remaining token.
    ///
    /// - Parameter json: Target json.
    func getremainingTokens(in json: String) {
        
        guard !json.isEmpty else { return }
        
        var tmpJSON = json
        
        // Due to some restrictions, it cannot be implemented with recursion,
        // so it can only use the loop algorithm
        for _ in  0 ..< json.count {
            
            guard !tmpJSON.isEmpty else { break }
            
            let last = tokens.last
            
            switch tmpJSON.removeFirst() {
                
                // Filter spaces and newlines.
                // This type of character will not cause format errors.
            case " ", "\t", "\n": break
                
            case ":":
                
                switch last {
                
                case .objectKey:
                    tokens.append(.colon)
                    
                default:
                    tokens.append(.unknown(":" + tmpJSON))
                    return
                }
                
            case ",":
                
                switch last {
                
                case .null, .link, .string, .number, .boolean, .objectEnd, .arrayEnd:
                    tokens.append(.comma)
                    
                default:
                    tokens.append(.unknown("," + tmpJSON))
                    return
                }
                
            case "{":
                
                if last == nil || last! != .objectBegin {
                    beginNodes.append(.object)
                    tokens.append(.objectBegin)
                    
                } else {
                    tokens.append(.unknown("{" + tmpJSON))
                    return
                }
                
            case "}":
                
                if beginNodes.last == .object {
                    beginNodes.removeLast()
                    tokens.append(.objectEnd)
                    
                } else {
                    tokens.append(.unknown("}" + tmpJSON))
                    return
                }
                
            case "[":
                
                if last == nil || last! != .arrayBegin {
                    beginNodes.append(.array)
                    tokens.append(.arrayBegin)
                    
                } else {
                    tokens.append(.unknown("[" + tmpJSON))
                    return
                }
                
            case "]":
                
                if beginNodes.last == .array {
                    beginNodes.removeLast()
                    tokens.append(.arrayEnd)
                    
                } else {
                    tokens.append(.unknown("]" + tmpJSON))
                    return
                }
                
            case "\"":
                
                // Determine whether the string is a complete string node.
                guard let index = tmpJSON.firstIndex(of: "\"") else {
                    tokens.append(.unknown(tmpJSON))
                    return
                }
                
                let startIndex = tmpJSON.startIndex
                
                let string = String(tmpJSON[startIndex ..< index])
                
                switch last {
                    
                case .objectBegin:
                    tokens.append(.objectKey(string))
                    
                case .arrayBegin, .colon:
                    
                    if let url = string.isValidURL {
                        tokens.append(.link(url))
                        
                    } else {
                        tokens.append(.string(string))
                    }
                    
                case .comma:
                    
                    // Need to determine whether it is currently in the object or in the array.
                    if beginNodes.last == .object {
                        tokens.append(.objectKey(string))
                        
                    } else if let url = string.isValidURL {
                        tokens.append(.link(url))
                        
                    } else {
                        tokens.append(.string(string))
                    }
                    
                default:
                    tokens.append(.unknown("\"" + tmpJSON))
                    return
                }
                
                tmpJSON.removeSubrange(startIndex ... index)
                
            case "n":
                
                let startIndex = tmpJSON.startIndex
                let bounds = startIndex ..< tmpJSON.index(startIndex, offsetBy: 3)
                
                // The character `n` should be processed in `case "\""`.
                // If it is not `null` and it hits the `case`, it should be classified as a syntax error.
                guard tmpJSON[bounds] == "ull" else {
                    tokens.append(.unknown("n" + tmpJSON))
                    return
                }
                
                tokens.append(.null)
                tmpJSON.removeSubrange(bounds)
                
            case "t":
                
                let startIndex = tmpJSON.startIndex
                let bounds = startIndex ..< tmpJSON.index(startIndex, offsetBy: 3)
                
                // The character `t` should be processed in `case "\""`.
                // If it is not `true` and it hits the `case`, it should be classified as a syntax error.
                guard tmpJSON[bounds] == "rue" else {
                    tokens.append(.unknown("t" + tmpJSON))
                    return
                }
                
                tokens.append(.boolean(true))
                tmpJSON.removeSubrange(bounds)
                
            case "f":
                
                let startIndex = tmpJSON.startIndex
                let bounds = startIndex ..< tmpJSON.index(startIndex, offsetBy: 4)
                
                // The character `f` should be processed in `case "\""`.
                // If it is not `false` and it hits the `case`, it should be classified as a syntax error.
                guard tmpJSON[bounds] == "alse" else {
                    tokens.append(.unknown("f" + tmpJSON))
                    return
                }
                
                tokens.append(.boolean(false))
                tmpJSON.removeSubrange(bounds)
                
            case let value:
                
                guard !tmpJSON.isEmpty && (value == "-" || value.isNumber) else {
                    tokens.append(.unknown(String(value) + tmpJSON))
                    return
                }
                
                var number = String(value)
                var _first: Character? = tmpJSON.removeFirst()
                
                while let first = _first {
                    
                    if first.isNumber || first == "." {
                        number += String(first)
                        _first = tmpJSON.removeFirst()
                        
                    } else {
                        
                        tmpJSON = String(first) + tmpJSON
                        _first = nil
                    }
                }
                
                guard !number.hasSuffix(".") else {
                    tokens.append(.unknown(String(value) + tmpJSON))
                    return
                }
                
                tokens.append(.number(number))
            }
        }
    }
}

// MARK: - Tools

fileprivate extension String {
    
    /// Check if the string is a valid URL.
    ///
    /// - Return: If it is a valid URL, return the unescaped string. Otherwise return nil.
    var isValidURL: String? {
        
        guard count > 1 else { return nil }
        
        let regex = "((https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        let string = removeEscaping()
        
        guard predicate.evaluate(with: string) else { return nil }
        
        return string
    }
    
    /// Remove escape characters in the string.
    ///
    /// Currently only supports replacement of "\\/".
    func removeEscaping() -> String {
        
        var string = self
        
        if string.contains("\\/") {
            string = string.replacingOccurrences(of: "\\/", with: "/")
        }
        
        return string
    }
}
