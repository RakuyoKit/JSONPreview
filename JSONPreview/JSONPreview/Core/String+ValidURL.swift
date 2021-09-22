//
//  String+ValidURL.swift
//  JSONPreview
//
//  Created by Rakuyo on 2021/9/22.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

private let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [
    "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
])

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
        
        if predicate.evaluate(with: string.lowercased()) {
            return ValidURL(urlString: string, isIP: false)
        }
        
        if ipPredicate.evaluate(with: string.lowercased()) {
            return ValidURL(urlString: string, isIP: true)
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
