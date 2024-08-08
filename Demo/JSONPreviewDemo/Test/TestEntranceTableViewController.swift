//
//  TestEntranceTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/27.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - TestEntranceTableViewController

final class TestEntranceTableViewController: ListTableViewController {
    init() {
        let dataSource: [[DemoCaseConfig]] = [
            [
                .init(
                    title: "VisionOS TableView Test",
                    action: { VisionOSTestViewController() }
                ),
            ],
        ]

        super.init(dataSource: dataSource)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
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
