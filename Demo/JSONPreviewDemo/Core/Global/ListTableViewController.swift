//
//  ListTableViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - ListTableViewController

class ListTableViewController: UITableViewController {
    private let dataSource: [[DemoCaseConfig]]
    
    init(dataSource: [[DemoCaseConfig]]) {
        self.dataSource = dataSource
        
        super.init(style: .grouped)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
    override func numberOfSections(in _: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        let config = dataSource[indexPath.section][indexPath.row]
        cell.textLabel?.text = config.title
        cell.detailTextLabel?.text = config.desc

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ListTableViewController {
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = dataSource[indexPath.section][indexPath.row].action() else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        0.01
    }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        .init(frame: .init(origin: .zero, size: .init(width: 0, height: 0.01)))
    }
}
