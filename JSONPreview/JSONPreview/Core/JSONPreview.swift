//
//  JSONPreview.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class JSONPreview: UIView {
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - jsonSlices: The slice of the JSON to be previewed. Can be created by `JSONDecorator`.
    ///   - style: See `HighlightStyle` for details.
    public init(jsonSlices: [JSONSlice], style: HighlightStyle = .default) {
        
        self.dataSource = jsonSlices
        self.highlightStyle = style
        
        super.init(frame: .zero)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// ScrollView responsible for scrolling in JSON area
    open lazy var jsonScrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        
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
        
        tableView.register(LineNumberTableViewCell.self, forCellReuseIdentifier: "LineNumberTableViewCell")
        
        return tableView
    }()

    /// TableView responsible for displaying JSON
    open lazy var jsonTableView: JSONPreviewTableView = {
        
        let tableView = JSONPreviewTableView(frame: .zero, style: .plain)
        
        tableView.backgroundColor = highlightStyle.color.jsonBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(JSONPreviewTableViewCell.self, forCellReuseIdentifier: "JSONPreviewTableViewCell")
        
        return tableView
    }()
    
    /// Data source responsible for display
    var dataSource: [JSONSlice]
    
    /// Highlight style
    let highlightStyle: HighlightStyle
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
        
//        lineNumberTableView.snp.makeConstraints {
//
//            $0.top.bottom.equalToSuperview()
//            $0.width.equalTo(55)
//
//            if #available(iOS 11.0, *) {
//                $0.left.equalTo(safeAreaLayoutGuide.snp.left)
//            } else {
//                $0.left.equalTo(snp.left)
//            }
//        }
//
//        jsonScrollView.snp.makeConstraints {
//
//            $0.left.equalTo(lineNumberTableView.snp.right)
//            $0.top.bottom.equalTo(lineNumberTableView)
//
//            if #available(iOS 11.0, *) {
//                $0.right.equalTo(safeAreaLayoutGuide.snp.right)
//            } else {
//                $0.right.equalTo(snp.right)
//            }
//        }
//
//        jsonTableView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//            $0.height.equalToSuperview()
//
//            widthConstraintEditable = $0.width.equalTo(calculateMaxWidth())
//        }
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
        
        if tableView.tag == JSONPreviewTableView.tag {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "JSONPreviewTableViewCell", for: indexPath) as! JSONPreviewTableViewCell
            
            cell.jsonLabel.tag = indexPath.row
            cell.jsonLabel.attributedText = slice.showContent
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineNumberTableViewCell", for: indexPath) as! LineNumberTableViewCell
            
            cell.numberLabel.text = slice.lineNumber
            cell.numberLabel.textColor = highlightStyle.color.lineText
            
            return cell
        }
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
