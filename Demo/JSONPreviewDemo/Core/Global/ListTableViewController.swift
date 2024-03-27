//
//  ListTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    init(dataSource: [DemoCaseConfig]) {
        self.dataSource = dataSource
        
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dataSource: [DemoCaseConfig]
}

// MARK: - Life cycle

extension ListTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "ListCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension ListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        let config = dataSource[indexPath.row]
        cell.textLabel?.text = config.title
        cell.detailTextLabel?.text = config.desc

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = dataSource[indexPath.row].action() else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return .init(frame: .init(origin: .zero, size: .init(width: 0, height: 0.01)))
    }
}
