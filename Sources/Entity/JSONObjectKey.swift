import Foundation

/// Used to enrich the information of the key of the object in json.
public struct JSONObjectKey {
    /// The object key.
    ///
    /// If this key is wrong, then the value is `""`.
    public let key: String
    
    /// Is the key wrong.
    public let isWrong: Bool
    
    /// Used to mark an incorrect key.
    public static let wrong: Self = .init(key: "", isWrong: true)
    
    fileprivate init(key: String, isWrong: Bool) {
        self.key = key
        self.isWrong = isWrong
    }
    
    public init(_ key: String) {
        self.init(key: key, isWrong: false)
    }
}

// MARK: - Hashable

extension JSONObjectKey: Hashable { }

// MARK: - Comparable

extension JSONObjectKey: Comparable {
    public static func < (lhs: JSONObjectKey, rhs: JSONObjectKey) -> Bool {
        if lhs.isWrong { return false }
        if rhs.isWrong { return true }
        return lhs.key < rhs.key
    }
}

// MARK: - ExpressibleByStringLiteral

extension JSONObjectKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
