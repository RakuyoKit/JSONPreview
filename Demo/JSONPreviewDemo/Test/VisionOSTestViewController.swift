//
//  TestViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/27.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

final class VisionOSTestViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let _view = UITableView(frame: .zero, style: .plain)
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.backgroundColor = .red
        _view.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        _view.delegate = self
        _view.dataSource = self
        _view.separatorColor = .yellow
        _view.separatorStyle = .singleLine
        
//        _view.sectionHeaderHeight = 0.0
//        _view.estimatedSectionHeaderHeight = 0.0
//        _view.sectionFooterHeight = 0.0
//        _view.estimatedSectionFooterHeight = 0.0
//        _view.separatorStyle = .none
//        _view.separatorInset = .init(top: -10, left: -10, bottom: -10, right: -10)
        
        return _view
    }()
}

// MARK: - Life cycle

extension VisionOSTestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "visionOS Test"
        
        view.backgroundColor = {
            guard #available(iOS 13.0, *) else { return .white }
            return .systemGroupedBackground
        }()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate

extension VisionOSTestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24.3
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: .init(x: 0, y: 0, width: 10, height: 0.001))
//        view.backgroundColor = .green
//        return view
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView(frame: .init(x: 0, y: 0, width: 10, height: 0.001))
//        view.backgroundColor = .white
//        return view
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.001
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.001
//    }
}

// MARK: - UITableViewDataSource

extension VisionOSTestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50//1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath)"
        cell.backgroundColor = .green
        cell.contentView.backgroundColor = .blue
        return cell
    }
}
