//
//  HighlightStyle.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/10.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

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
    public init(expandIcon: UIImage? = nil, foldIcon: UIImage? = nil, color: HighlightColor = .default) {
        
        self.expandIcon = expandIcon ?? UIImage(name: "expand")!
        self.foldIcon = foldIcon ?? UIImage(name: "fold")!
        self.color = color
    }
    
    /// The icon of the expand button.
    public let expandIcon: UIImage
    
    /// The icon of the fold button.
    public let foldIcon: UIImage
    
    /// Color-related configuration, see `HighlightColor` for details
    public let color: HighlightColor
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
