//
//  TableViewExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/9.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

final class TableViewExampleViewController: UITableViewController {
    private lazy var dataSource: [ListConfig] = [
        .desc("""
            This file contains two sample scenes, which can also be treated as three, that is, a composite scene when the two scenes are used together.
            """),
        .desc("""
            1. The Cell hosting JSONPreview needs to dynamically change its height.
            
            A common situation is: JSONPreview is displayed in the middle of the list. When the node is expanded or collapsed, the height of the Cell needs to change accordingly.
            
            The specific effects are as follows:
            """),
        .json(.init(content: ExampleJSON.legalJson, heightStyle: .dynamic)),
        .desc("""
            One thing you need to pay attention to:
            the method shown in this example is not the only one. For example, you can also monitor changes in contentSize through KVO and then update the Cell height.
            """),
        .desc("""
            2. The height of JSONPreview is fixed.
            
            Its value is the maximum height of JSON. Unaffected by the collapsed or expanded state of slice nodes.
            
            Often this kind of JSON appears at the end of the list, and its height does not have much impact on the overall list.
            """),
        .json(.init(content: ExampleJSON.mostComprehensive, heightStyle: .fixed)),
        .desc("""
            3. Mixed use.
            
            As this example shows, mix both situations.
            """),
        .desc("Below are some placeholder Cells that you can use to check the reuse of Cells."),
    ] + (1 ... 30).map { ListConfig.desc("\($0)") }
    
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
            func _preview<C: BaseJSONCell>(initialState state: JSONSlice.State, cell: C) {
                cell.previewView.tag = index
                
                if let _decorator = model.decorator {
                    cell.previewView.tag = index
                    cell.previewView.update(with: _decorator)
                    
                } else {
                    cell.previewView.preview(model.content, initialState: state) { (decorator) in
                        guard model.height == nil else { return }
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let this = self else { return }
                            
                            // Sometimes the obtained height is inaccurate, differing by 5.
                            // If you don't care about this error, you can do this:
                            model.height = cell.previewView.contentSize.height // + 5
                            
                            model.decorator = decorator
                            
                            this.dataSource[index] = .json(model)
                            this.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
            
            switch model.heightStyle {
            case .fixed:
                let cell = tableView.dequeueReusableCell(withIdentifier: "JSON Cell", for: indexPath) as! JSONCell
                _preview(initialState: .expand, cell: cell)
                return cell
                
            case .dynamic:
                let cell = tableView.dequeueReusableCell(withIdentifier: "JSON Delegate Cell", for: indexPath) as! JSONDelegateCell
                
                cell.previewView.delegate = self
                
                _preview(initialState: .folded, cell: cell)
                
                return cell
            }
            
        case .desc(let content):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .black
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
    func jsonPreview(_ view: JSONPreview, didChangeSliceState slice: JSONSlice, decorator: JSONDecorator) {
        let indexPath = IndexPath(row: view.tag, section: 0)
        let index = indexPath.row
        
        guard case .json(var model) = dataSource[index] else { return }
        
        model.height = view.contentSize.height
        model.decorator = decorator
        
        dataSource[index] = .json(model)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - Config Model

private enum ListConfig {
    struct JSON {
        enum HeightStyle {
            case fixed
            
            case dynamic
        }
        
        let content: String
        
        var decorator :JSONDecorator? = nil
        
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
        previewView.bounces = false
        
#if !os(tvOS)
        previewView.scrollsToTop = false
#endif
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

private final class JSONCell: BaseJSONCell { }

private final class JSONDelegateCell: BaseJSONCell { }
