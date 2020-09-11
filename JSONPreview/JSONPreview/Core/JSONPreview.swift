//
//  JSONPreview.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class JSONPreview: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    /// ScrollView responsible for scrolling in JSON area
    open lazy var jsonScrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.tag = Constant.scrollViewTag
        scrollView.backgroundColor = .clear
        scrollView.bounces = false
        
        scrollView.delegate = self
        
        return scrollView
    }()
    
    /// TableView responsible for displaying row numbers
    open lazy var lineNumberTableView: LineNumberTableView = {
        
        let tableView = LineNumberTableView(frame: .zero, style: .plain)
        
        tableView.backgroundColor = highlightStyle.color.lineBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()

    /// TableView responsible for displaying JSON
    open lazy var jsonTableView: JSONPreviewTableView = {
        
        let tableView = JSONPreviewTableView(frame: .zero, style: .plain)
        
        tableView.backgroundColor = highlightStyle.color.jsonBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()
    
    /// Data source responsible for display
    public lazy var dataSource: [JSONSlice] = []
    
    /// Highlight style
    public var highlightStyle: HighlightStyle = .default {
        didSet {
            lineNumberTableView.backgroundColor = highlightStyle.color.lineBackground
            jsonTableView.backgroundColor = highlightStyle.color.jsonBackground
        }
    }
}

// MARK: - Constant

extension JSONPreview {
    
    enum Constant {
        
        /// Tag of `jsonScrollView`
        fileprivate static let scrollViewTag: Int = 0
        
        static let lineHeight: CGFloat = 24.0
        
        static let JSONFont = UIFont(name:"Helvetica Neue", size: 16)!
    }
}

private extension JSONPreview {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(lineNumberTableView)
        addSubview(jsonScrollView)
        
        jsonScrollView.addSubview(jsonTableView)
    }
    
    func addInitialLayout() {
        
        // lineNumberTableView
        addLineNumberTableViewLayout()
        
        // jsonScrollView
        addJSONScrollViewLayout()
        
        // jsonTableView
        addJSONTableViewLayout()
    }
    
    func addLineNumberTableViewLayout() {
        
        var constraints = [
            lineNumberTableView.topAnchor.constraint(equalTo: self.topAnchor),
            lineNumberTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            lineNumberTableView.widthAnchor.constraint(equalToConstant: 55)
        ]
        
        constraints.append(lineNumberTableView.leftAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return self.safeAreaLayoutGuide.leftAnchor
            } else {
                return self.leftAnchor
            }
        }()))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addJSONScrollViewLayout() {
        
        var constraints = [
            jsonScrollView.leftAnchor.constraint(equalTo: lineNumberTableView.rightAnchor),
            jsonScrollView.topAnchor.constraint(equalTo: lineNumberTableView.topAnchor),
            jsonScrollView.bottomAnchor.constraint(equalTo: lineNumberTableView.bottomAnchor),
        ]
        
        constraints.append(jsonScrollView.rightAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return self.safeAreaLayoutGuide.rightAnchor
            } else {
                return self.rightAnchor
            }
        }()))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addJSONTableViewLayout() {
        
        var constraints = [
            jsonTableView.leftAnchor.constraint(equalTo: jsonScrollView.leftAnchor),
            jsonTableView.rightAnchor.constraint(equalTo: jsonScrollView.rightAnchor),
            jsonTableView.topAnchor.constraint(equalTo: jsonScrollView.topAnchor),
            jsonTableView.bottomAnchor.constraint(equalTo: jsonScrollView.bottomAnchor),
            jsonTableView.heightAnchor.constraint(equalTo: jsonScrollView.heightAnchor),
            
            // widthConstraintEditable = $0.width.equalTo(calculateMaxWidth())
            jsonTableView.widthAnchor.constraint(equalToConstant: 1000)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITableViewDelegate

extension JSONPreview: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.lineHeight
    }
}

// MARK: - UITableViewDataSource

extension JSONPreview: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let slice = dataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.numberOfLines = 1
        
        if tableView.tag == JSONPreviewTableView.tag {
            
            cell.selectionStyle = .none
            
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.isUserInteractionEnabled = true
            cell.textLabel?.attributedText = slice.showContent
            
        } else {
            
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.text = slice.lineNumber
            cell.textLabel?.textColor = highlightStyle.color.lineText
        }
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension JSONPreview: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView.tag == Constant.scrollViewTag else { return }
        
        let offsetY = scrollView.contentOffset.y
        let offset = CGPoint(x: 0, y: offsetY)
        
        // Slide the JSON ScrollView to scroll the row number and TableView up and down
        lineNumberTableView.contentOffset = offset
        jsonTableView.contentOffset = offset
        
        // Record the original ContentSize
        let oldContentSize = jsonScrollView.contentSize
        
        // Update constraints
//        jsonTableView.snp.updateConstraints {
//            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: offsetY, left: 0, bottom: 0, right: 0))
//        }
        
        layoutIfNeeded()
        
        // Restore the original ContentSize
        jsonScrollView.contentSize = oldContentSize
    }
}
