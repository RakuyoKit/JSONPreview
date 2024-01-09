//
//  TableViewExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/9.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

class TableViewExampleViewController: UITableViewController {
    private lazy var dataSource: [ListConfig] = [
        .desc("""
            If you use this framework in conjunction with UITableView, we recommend that a list contain only one JSON Cell, so as to avoid some unresolved Cell reuse issues.
            """),
        .desc("""
            See the example below. UITableView does not update its height after obtaining the initial height. The height of Cell is always the maximum height of JSONPreview.
            """),
        .json(.init(content: ExampleJSON.mostComprehensive, heightStyle: .fixed)),
        .desc("""
            If you want the height of the Cell to change as you fold/expand JSON, then unfortunately, there are still some problems with this feature that have not been resolved.
            """),
        .desc("This file contains some unfinished test code, if you are interested you can try it out."),
//        .json(.init(content: ExampleJSON.mostComprehensive, heightStyle: .dynamic(nil))),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "In TableView example"
        
        view.backgroundColor = .white
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(JSONCell.self, forCellReuseIdentifier: "JSON Cell")
        tableView.register(JSONDelegateCell.self, forCellReuseIdentifier: "JSON Delegate Cell")
    }
}

// MARK: - UITableViewDataSource

extension TableViewExampleViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        switch dataSource[index] {
        case .json(var model):
            func _preview<C: BaseJSONCell>(
                initialState state: JSONSlice.State,
                cell: C,
                completion: (() -> Void)? = nil
            ) {
                cell.previewView.tag = index
                cell.previewView.preview(model.content, initialState: state) { _ in
                    guard model.height == nil else { return }
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let this = self else { return }
                        
                        model.height = cell.previewView.contentSize.height
                        completion?()
                        this.dataSource[index] = .json(model)
                        this.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            
            switch model.heightStyle {
            case .fixed:
                let cell = tableView.dequeueReusableCell(withIdentifier: "JSON Cell", for: indexPath) as! JSONCell
                _preview(initialState: .expand, cell: cell)
                return cell
                
            case .dynamic(let decorator):
                let cell = tableView.dequeueReusableCell(withIdentifier: "JSON Delegate Cell", for: indexPath) as! JSONDelegateCell
                
                cell.previewView.delegate = self
                
                if let _decorator = decorator {
                    cell.previewView.tag = index
                    cell.previewView.highlightStyle = .default
                    cell.previewView.decorator = _decorator
                    
                } else {
                    _preview(initialState: .expand, cell: cell) {
                        model.heightStyle = .dynamic(cell.previewView.decorator)
                    }
                }
                
                return cell
            }
            
        case .desc(let content):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = content
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension TableViewExampleViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.row] {
        case .desc:
            return UITableView.automaticDimension
            
        case .json(let model):
            return model.height ?? UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - JSONPreviewDelegate

extension TableViewExampleViewController: JSONPreviewDelegate {
    func jsonPreview(_ view: JSONPreview, didChangeJSONSliceState slice: JSONSlice) {
        let indexPath = IndexPath(row: view.tag, section: 0)
        
        guard case .json(var model) = dataSource[indexPath.row] else { return }
        
        model.height = view.contentSize.height
        model.heightStyle = .dynamic(view.decorator)
        
        dataSource[indexPath.row] = .json(model)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - Config Model

private enum ListConfig {
    struct JSON {
        enum HeightStyle {
            case fixed
            
            case dynamic(JSONDecorator?)
        }
        
        let content: String
    
        var height: CGFloat? = nil
        
        var heightStyle: HeightStyle
    }
    
    case json(JSON)
    
    case desc(String)
}

// MARK: - Cell

private class BaseJSONCell: UITableViewCell {
    lazy var previewView = JSONPreview()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(previewView)
        
        configPreview()
        
        addLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configPreview() {
        previewView.scrollsToTop = false
    }
    
    func addLayout() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

private class JSONCell: BaseJSONCell { }

private class JSONDelegateCell: BaseJSONCell { }
