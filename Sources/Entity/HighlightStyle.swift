//
//  HighlightStyle.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

public typealias AttributedString = NSMutableAttributedString
public typealias AttributedKey = AttributedString.Key
public typealias StyleInfos = [AttributedKey : Any]

/// Highlight style configuration
public struct HighlightStyle {
    /// Initialization method
    ///
    /// For all the following parameters, the default configuration will be used when it is `nil`
    ///
    /// - Parameters:
    ///   - expandIcon: The icon of the expand button.
    ///   - foldIcon: The icon of the fold button.
    ///   - color: Color-related configuration. See `HighlightColor` for details.
    ///   - lineFont: Text font in line number area.
    ///   - jsonFont: Text font in json preview area.
    ///   - lineHeight: Line height of JSON preview area.
    public init(
        expandIcon: UIImage? = nil,
        foldIcon: UIImage? = nil,
        color: HighlightColor = .`default`,
        lineFont: UIFont? = nil,
        jsonFont: UIFont? = nil,
        lineHeight: CGFloat = 24
    ) {
        let getImage: (String) -> UIImage? = {
            #if SWIFT_PACKAGE
            let bundle = Bundle.module
            #else
            guard 
                let resourcePath = Bundle(for: JSONPreview.self).resourcePath,
                let bundle = Bundle(path: resourcePath + "/JSONPreviewBundle.bundle") 
            else {
                return UIImage(named: $0)
            }
            #endif
            
            return UIImage(named: $0, in: bundle, compatibleWith: nil)
        }
        
        self.expandIcon = expandIcon ?? getImage("expand")!
        self.foldIcon = foldIcon ?? getImage("fold")!
        self.color = color
        self.lineFont = lineFont ?? UIFont(name:"Helvetica Neue", size: 16)!
        self.jsonFont = jsonFont ?? UIFont(name:"Helvetica Neue", size: 16)!
        self.lineHeight = lineHeight
    }
    
    /// The icon of the expand button.
    public let expandIcon: UIImage
    
    /// The icon of the fold button.
    public let foldIcon: UIImage
    
    /// Color-related configuration, see `HighlightColor` for details.
    public let color: HighlightColor
    
    /// Text font in line number area.
    public let lineFont: UIFont
    
    /// Text font in json preview area.
    public let jsonFont: UIFont
    
    /// Line height of JSON preview area.
    public let lineHeight: CGFloat
}

public extension HighlightStyle {
    /// Default style configuration.
    static let `default` = HighlightStyle()
    
    /// A darker style scheme that the author likes.
    static let mariana = HighlightStyle(color: .mariana)
}

fileprivate extension UIImage {
    convenience init?(name: String) {
        if let resourcePath = Bundle(for: JSONPreview.self).resourcePath,
            let bundle = Bundle(path: resourcePath + "JSONPreview.bundle") {
            
            self.init(named: name, in: bundle, compatibleWith: nil)
            
        } else {
            self.init(named: name)
        }
    }
}
