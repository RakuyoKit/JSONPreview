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
    private lazy var jsonScrollView: UIScrollView = {
        
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()

    /// TableView responsible for displaying JSON
    open lazy var jsonTableView: JSONPreviewTableView = {
        
        let tableView = JSONPreviewTableView(frame: .zero, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(JSONPreviewCell.self, forCellReuseIdentifier: "JSONPreviewCell")
        
        return tableView
    }()
    
    /// Data source responsible for display
    private lazy var dataSource: [JSONSlice] = []
    
    /// Highlight style
    private var highlightStyle: HighlightStyle = .default {
        didSet {
            lineNumberTableView.backgroundColor = highlightStyle.color.lineBackground
            jsonTableView.backgroundColor = highlightStyle.color.jsonBackground
        }
    }
    
    /// Constraint settings at the top of `jsonTableView`
    private lazy var jsonTableViewTopConstraint: NSLayoutConstraint? = nil
}

public extension JSONPreview {
    
    /// Preview json.
    ///
    /// - Parameters:
    ///   - json: The json to be previewed
    ///   - style: Highlight style. See `HighlightStyle` for details.
    func preview(_ json: String, style: HighlightStyle = .default) {
        
        dataSource = JSONDecorator.highlight(json, style: style)
        highlightStyle = style
    }
    
    /// Preview json.
    ///
    /// - Parameters:
    ///   - slice: The slice array of json to be previewed can be obtained through `JSONDecorator`.
    ///   - style: Highlight style. See `HighlightStyle` for details.
    func preview(_ slice: [JSONSlice], style: HighlightStyle = .default) {
        
        dataSource = slice
        highlightStyle = style
    }
}

// MARK: - Constant

private extension JSONPreview {
    
    enum Constant {
        
        /// Tag of `jsonScrollView`
        static let scrollViewTag: Int = 0
        
        /// Height of each row
        static let lineHeight: CGFloat = 24.0
    }
}

// MARK: - UI

extension JSONPreview {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
//        let maxWidth = calculateMaxWidth()
//
//        // Update width
//        widthConstraintEditable?.constraint.update(offset: maxWidth)
        
        // Set it after a little delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            guard let this = self else { return }
            
            // Set `contentSize` manually instead of automatic calculation by AutoLayout
            this.jsonScrollView.contentSize = CGSize(width: 1000, height: Constant.lineHeight * CGFloat(this.dataSource.count))
        }
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
            jsonTableView.bottomAnchor.constraint(equalTo: jsonScrollView.bottomAnchor),
            jsonTableView.heightAnchor.constraint(equalTo: jsonScrollView.heightAnchor),
            
            // widthConstraintEditable = $0.width.equalTo(calculateMaxWidth())
            jsonTableView.widthAnchor.constraint(equalToConstant: 1000)
        ]
        
        jsonTableViewTopConstraint = jsonTableView.topAnchor.constraint(equalTo: jsonScrollView.topAnchor)
        
        constraints.append(jsonTableViewTopConstraint!)
        
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
        
        if tableView.tag == JSONPreviewTableView.tag {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "JSONPreviewCell", for: indexPath) as! JSONPreviewCell
            cell.jsonView.attributedText = slice.showContent
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.backgroundColor = .clear
        
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = slice.lineNumber
        cell.textLabel?.font = highlightStyle.lineFont
        cell.textLabel?.textColor = highlightStyle.color.lineText
        
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
        jsonTableViewTopConstraint?.constant = offsetY
        
        layoutIfNeeded()
        
        // Restore the original ContentSize
        jsonScrollView.contentSize = oldContentSize
    }
}
