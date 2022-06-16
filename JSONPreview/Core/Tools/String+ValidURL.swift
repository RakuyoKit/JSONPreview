//
//  String+ValidURL.swift
//  JSONPreview
//
//  Created by Rakuyo on 2021/9/22.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// Used to match any url, including ip addresses.
private let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [
    "((?:http|https)://)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
])

/// Used to match ip addresses.
private let ipPredicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [
    "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
])

struct ValidURL {
    let urlString: String
    let isIP: Bool
    
    var openingURL: URL? {
        if isIP {
            // Add "http" prefix to ip address
            return URL(string: "http://" + urlString)
        }
        
        guard let _url = URL(string: urlString), _url.scheme != nil else {
            // Add the "https" prefix to the general address
            return URL(string: "https://" + urlString)
        }
        
        return _url
    }
}

extension String {
    /// Check if the string is a valid URL.
    ///
    /// - Return: If it is a valid URL, return the unescaped string. Otherwise return nil.
    var validURL: ValidURL? {
        guard count > 1 else { return nil }
        
        let string = removeEscaping()
        
        // Since `predicate` can also match ip,
        // use `ipPredicate` to match ip first,
        // and then use `predicate` to match if it is not.
        if ipPredicate.evaluate(with: string.lowercased()) {
            return ValidURL(urlString: string, isIP: true)
        }
        
        if predicate.evaluate(with: string.lowercased()) {
            return ValidURL(urlString: string, isIP: false)
        }
        
        return nil
    }
    
    /// Remove escape characters in the string.
    ///
    /// Currently only supports replacement of "\\/".
    fileprivate func removeEscaping() -> String {
        var string = self
        
        if string.contains("\\/") {
            string = string.replacingOccurrences(of: "\\/", with: "/")
        }
        
        return string
    }
}
