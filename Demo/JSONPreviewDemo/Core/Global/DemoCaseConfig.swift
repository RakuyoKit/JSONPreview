//
//  DemoCaseConfig.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

struct DemoCaseConfig {
    let title: String
    
    let desc: String?
    
    let action: () -> UIViewController?
    
    init(
        title: String,
        desc: String? = nil,
        action: @escaping () -> UIViewController?
    ) {
        self.title = title
        self.desc = desc
        self.action = action
    }
}
