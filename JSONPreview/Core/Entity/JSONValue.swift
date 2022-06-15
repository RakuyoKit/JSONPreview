//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

public enum JSONValue: Equatable {
    case string(String, wrong: String? = nil)
    case number(String, wrong: String? = nil)
    case bool(Bool, wrong: String? = nil)
    case null(wrong: String? = nil)
    
    case array([JSONValue])
    case object([JSONObjectKey: JSONValue])
    
    case unknown(String)
}

extension JSONValue {
    public enum ValueType {
        case wrong
        case right(isContainer: Bool)
    }
    
    public var isRight: ValueType {
        switch self {
        case .unknown:
            return .wrong
            
        case .string(_, let wrong):
            return wrong == nil ? .right(isContainer: false) : .wrong
            
        case .number(_, let wrong):
            return wrong == nil ? .right(isContainer: false) : .wrong
            
        case .bool(_, let wrong):
            return wrong == nil ? .right(isContainer: false) : .wrong
            
        case .null(let wrong):
            return wrong == nil ? .right(isContainer: false) : .wrong
            
        case .array(let array):
            guard let last = array.last else {
                return .right(isContainer: true)
            }
            
            switch last.isRight {
            case .right:
                return .right(isContainer: true)
            case .wrong:
                return .wrong
            }
            
        case .object(let object):
            for value in object.values {
                guard case .wrong = value.isRight else { continue }
                return .wrong
            }
            return .right(isContainer: true)
        }
    }
    
    public func appendWrong(_ wrong: String) -> Self {
        switch self {
        case .bool(let value, _):
            return .bool(value, wrong: wrong)
            
        case .number(let value, _):
            return .number(value, wrong: wrong)
            
        case .string(let value, _):
            return .string(value, wrong: wrong)
            
        case .null:
            return .null(wrong: wrong)
            
        default:
            return self
        }
    }
}

extension JSONValue {
    public var debugDataTypeDescription: String {
        switch self {
        case .array:
            return "an array"
        case .bool:
            return "bool"
        case .number:
            return "a number"
        case .string:
            return "a string"
        case .object:
            return "a dictionary"
        case .null:
            return "null"
        case .unknown:
            return "unknown json value"
        }
    }
}
