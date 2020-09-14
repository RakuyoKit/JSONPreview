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
        
        textView.clickDelegate = self
        
        return textView
    }()
    
    /// Line number view, height of each row.
    private lazy var lineHeight: CGFloat = 0
    
    /// Data source for line number view
    private var lineDataSource: [String] = [] {
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
    
    /// JSON Decoder
    private var decorator: JSONDecorator! {
        didSet {
            
            // Calculate the line height of the line number display area
            calculateLineHeight()
            
            // Combine the slice result into a string
            let tmp = NSMutableAttributedString(string: "")
            
            decorator.slices.forEach {
                tmp.append($0.expand)
                tmp.append(decorator.wrapString)
            }
            
            // Switch to the main thread to update the UI
            DispatchQueue.main.async { [weak self] in
                
                guard let this = self else { return }
                
                this.jsonTextView.attributedText = tmp
                this.lineDataSource = (1 ... this.decorator.slices.count).map(String.init)
            }
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
        
        highlightStyle = style
        
        DispatchQueue.global().async { [weak self] in
            self?.decorator = JSONDecorator.highlight(json, style: style)
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
    
    /// Calculate the line height of the line number display area
    func calculateLineHeight() {
        
        let attString = decorator.slices[0].expand
        
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
        
        lineHeight = rect.height
    }
}

// MARK: - JSONTextViewClickDelegate

extension JSONPreview: JSONTextViewClickDelegate {
    
    public func textView(_ textView: JSONTextView, didClickZoomAt pointY: CGFloat, characterIndex: Int) {
        
        // Get the number of rows
        let row = Int(floor(pointY / lineHeight))
        
        let slices = decorator.slices
        
        guard row < slices.count else { return }
        
        // Record the current offset to restore the offset after modifying the text
        let oldOffset = textView.contentOffset
        
        defer {
            
            // Need to delay a small number of seconds,
            // otherwise the modification will not take effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                
                // Restore offset
                textView.contentOffset = oldOffset
            }
        }
        
//        let prefixString = textView.attributedText.attributedSubstring(from: NSRange(location: 0, length: characterIndex))
        
        let slice = slices[row]
        
        switch slice.state {
            
        case .expand:
            print("点击了折叠按钮")
            
            decorator.slices[row].state = .folded
//            textView.attributedText = prefixString
            
        case .folded:
            print("点击了展开按钮")
            
            decorator.slices[row].state = .expand
//            textView.attributedText = prefixString
        }
    }
}

// MARK: - UITableViewDelegate

extension JSONPreview: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return lineHeight
    }
}

// MARK: - UITableViewDataSource

extension JSONPreview: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = lineDataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.backgroundColor = .clear
        
        cell.textLabel?.text = row
        cell.textLabel?.textAlignment = .right
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
