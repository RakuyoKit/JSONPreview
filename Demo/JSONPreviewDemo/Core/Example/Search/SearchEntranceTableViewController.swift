//
//  SearchEntranceTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//
#if !os(tvOS)
import UIKit

final class SearchEntranceTableViewController: ListTableViewController {
    init() {
        super.init(dataSource: [
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
        ])
    }
    
    required init?(coder: NSCoder) {
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
#endif
