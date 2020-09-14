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
    
    /// TextView responsible for displaying JSON
    open lazy var jsonTextView: JSONTextView = {
        
        let textView = JSONTextView()
        
        textView.delegate = self
        
        return textView
    }()
    
    private lazy var lineHeight: CGFloat = 0
    
    /// Data source responsible for display
    private var dataSource: [JSONSlice] = [] {
        didSet { lineNumberTableView.reloadData() }
    }
    
    /// Highlight style
    private var highlightStyle: HighlightStyle = .default {
        didSet {
            lineNumberTableView.backgroundColor = highlightStyle.color.lineBackground
            jsonTextView.backgroundColor = highlightStyle.color.jsonBackground
            
            jsonTextView.textContainerInset = UIEdgeInsets(
                top: 0, left: 10, bottom: 0, right: 10
            )
        }
    }
    
    /// Constraint settings at the top of `jsonTextView`
    private lazy var jsonTextViewTopConstraint: NSLayoutConstraint? = nil
}

public extension JSONPreview {
    
    /// Preview json.
    ///
    /// - Parameters:
    ///   - json: The json to be previewed
    ///   - style: Highlight style. See `HighlightStyle` for details.
    func preview(_ json: String, style: HighlightStyle = .default) {
        
        DispatchQueue.global().async { [weak self] in
            
            guard let this = self else { return }
            
            let result = JSONDecorator.highlight(json, style: style)
            
            // Combine the slice result into a string
            let tmp = NSMutableAttributedString(string: "")
            
            result.slices.forEach {
                tmp.append($0.expand)
                tmp.append(result.wrapString)
            }
            
            // Calculate the height of each row
            let attString = result.slices[0].expand
            
            var tmpAtt: [NSAttributedString.Key : Any] = [:]
            
            attString.enumerateAttributes(in: NSRange(location: 0, length: attString.length)) { (values, _, _) in
                values.forEach { tmpAtt[$0] = $1 }
            }
            
            let rect = (attString.string as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: tmpAtt,
                context: nil
            )
            
            this.lineHeight = rect.height
            
            // Switch to the main thread to update the UI
            DispatchQueue.main.async { [weak this] in
                
                guard let safeThis = this else { return }
                
                safeThis.highlightStyle = style
                safeThis.dataSource = result.slices
                
                safeThis.jsonTextView.attributedText = tmp
            }
        }
    }
}

// MARK: - Constant

private extension JSONPreview {
    
    enum Constant {
        
        /// Tag of `jsonScrollView`
        static let scrollViewTag: Int = 0
        
        /// Height of each row
        static let lineHeight: CGFloat = 24
        
        /// Fixed width of `lineNumberTableView`
        static let lineWith: CGFloat = 55
    }
}

// MARK: - Config

private extension JSONPreview {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(lineNumberTableView)
        addSubview(jsonScrollView)
        
        jsonScrollView.addSubview(jsonTextView)
    }
    
    func addInitialLayout() {
        
        // lineNumberTableView
        addLineNumberTableViewLayout()
        
        // jsonScrollView
        addJSONScrollViewLayout()
        
        // jsonTextView
        addJSONTextViewLayout()
    }
}

// MARK: - UI

private extension JSONPreview {
    
    func addLineNumberTableViewLayout() {
        
        var constraints = [
            lineNumberTableView.widthAnchor.constraint(equalToConstant: Constant.lineWith),
            lineNumberTableView.topAnchor.constraint(equalTo: topAnchor),
            lineNumberTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        constraints.append(lineNumberTableView.leftAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return safeAreaLayoutGuide.leftAnchor
            } else {
                return leftAnchor
            }
        }()))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addJSONScrollViewLayout() {
        
        var constraints = [
            jsonScrollView.leftAnchor.constraint(equalTo: lineNumberTableView.rightAnchor, constant: -1),
            jsonScrollView.topAnchor.constraint(equalTo: topAnchor),
            jsonScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        constraints.append(jsonScrollView.rightAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return safeAreaLayoutGuide.rightAnchor
            } else {
                return rightAnchor
            }
        }()))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addJSONTextViewLayout() {
        
        var constraints = [
            jsonTextView.leftAnchor.constraint(equalTo: jsonScrollView.leftAnchor),
            jsonTextView.rightAnchor.constraint(equalTo: jsonScrollView.rightAnchor),
            jsonTextView.bottomAnchor.constraint(equalTo: jsonScrollView.bottomAnchor),
        ]
        
        jsonTextViewTopConstraint = jsonTextView.topAnchor.constraint(equalTo: jsonScrollView.topAnchor)
        
        constraints.append(jsonTextViewTopConstraint!)
        
        NSLayoutConstraint.activate(constraints)
        
        jsonTextView.setContentHuggingPriority(.required, for: .vertical)
        jsonTextView.setContentHuggingPriority(.required, for: .horizontal)
    }
}

// MARK: - JSONTextViewClickDelegate

extension JSONPreview: JSONTextViewClickDelegate {
    
    public func textViewDidClickZoom(_ textView: JSONTextView) {
        
        let index = textView.tag
        
        let slice = dataSource[index]
        
        switch slice.state {
        
        case .expand:
            dataSource[index].state = .folded
            textView.attributedText = slice.folded
            
        case .folded:
            dataSource[index].state = .expand
            textView.attributedText = slice.expand
            
        case .hidden: break
        }
    }
}

// MARK: - UITextViewDelegate

extension JSONPreview: UITextViewDelegate { }

// MARK: - UITableViewDelegate

extension JSONPreview: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return lineHeight
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
        jsonTextView.contentOffset = offset
        
        // Record the original ContentSize
        let oldContentSize = jsonScrollView.contentSize
        
        // Update constraints
        jsonTextViewTopConstraint?.constant = offsetY
        layoutIfNeeded()
        
        // Restore the original ContentSize
        jsonScrollView.contentSize = oldContentSize
    }
}
