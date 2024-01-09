//
//  EntranceTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

class EntranceTableViewController: UITableViewController {
    private let dataSource: [DemoCaseConfig] = [
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
        .init( 
            title: "In UITableView",
            desc: "Show how to use it in UITableView and dynamically adapt to Cell height.",
            action: { TableViewExampleViewController() }
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
    ]
}

// MARK: - UITableViewDataSource

extension EntranceTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = config.title
        cell.detailTextLabel?.text = config.desc
        cell.detailTextLabel?.numberOfLines = 0
        
        if #available(iOS 13.0, *) {
            cell.detailTextLabel?.textColor = .secondaryLabel
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EntranceTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = dataSource[indexPath.row].action() else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - DemoCaseConfig

private struct DemoCaseConfig {
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
