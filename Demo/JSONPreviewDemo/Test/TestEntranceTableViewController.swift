//
//  TestEntranceTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/27.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

final class TestEntranceTableViewController: ListTableViewController {
    init() {
        super.init(dataSource: [
            [
                .init(
                    title: "VisionOS TableView Test",
                    action: { VisionOSTestViewController() }
                ),
                .init(
                    title: "Wrap Test",
                    action: { WrapTestViewController() }
                ),
            ]
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life cycle

extension TestEntranceTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test Entrance"
    }
}
