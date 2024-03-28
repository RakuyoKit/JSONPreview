//
//  EntranceTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

final class EntranceTableViewController: ListTableViewController {
    init() {
        var dataSource: [DemoCaseConfig] = [
            .init(
                title: "Basic",
                desc: "The most basic, out-of-the-box example.",
                action: { BasicExampleViewController() }
            ),
            .init(
                title: "Custom style",
                desc: "This example only shows the usage when customizing colors, using another set of colors built into JSONPreview. You can follow suit to make your own color scheme.",
                action: { CustomStyleExampleViewController() }
            ),
        ]
        
#if os(tvOS)
        dataSource.append(contentsOf: [
            .init(
                title: "Wrap",
                desc: "This example shows the rendering and interactive effects of JSONPreview when displaying JSON without breaking lines. This example is built specifically for tvOS.",
                action: { TVOSWrapExampleViewController() }
            ),
        ])
#else
        dataSource.append(contentsOf: [
            .init(
                title: "Automatic Wrap",
                desc: "This example mainly demonstrates the rendering effect of JSON when lines are automatically wrapped and not.",
                action: { WrapExampleViewController() }
            ),
            .init(
                title: "Initial folded",
                desc: "Initial collapse of all JSON nodes. You need to expand each node manually.",
                action: { InitialFoldedExampleViewController() }
            ),
            .init(
                title: "Hide line number",
                desc: "Example of how to hide line numbers.",
                action: { HideLineNumberExampleViewController() }
            ),
            .init(
                title: "In UITableView",
                desc: "Show how to use it in UITableView and dynamically adapt to Cell height.",
                action: { TableViewExampleViewController() }
            ),
            .init(
                title: "Seach",
                desc: "Related examples of search functionality.",
                action: { SearchEntranceTableViewController() }
            ),
        ])
#endif
        
        super.init(dataSource: [
            dataSource,
            [
                .init(
                    title: "Test",
                    desc: "Not used to demonstrate functionality, but used for internal testing.",
                    action: { TestEntranceTableViewController() }
                )
            ]
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life cycle

extension EntranceTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "JSONPreview Demo"
    }
}
