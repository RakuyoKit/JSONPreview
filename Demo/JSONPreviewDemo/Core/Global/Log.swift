//
//  Log.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/8/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import Foundation

enum Log {
    static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        // swiftlint:disable:next no_direct_standard_out_logs
        Swift.print(items, separator: separator, terminator: terminator)
    }
}
