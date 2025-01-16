//
//  SearchEntranceTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - SearchEntranceTableViewController

final class SearchEntranceTableViewController: ListTableViewController {
    init() {
        let dataSource: [[DemoCaseConfig]] = [
            [
                .init(
                    title: "Basic",
                    desc: "Covers all basic usage of the search function.",
                    action: { BasicSearchExampleViewController() }
                ),
                .init(
                    title: "Custom Config",
                    desc: "Some examples of custom configurations.",
                    action: { CustomSearchExampleViewController() }
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

extension SearchEntranceTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search Example List"
    }
}
