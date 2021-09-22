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
    
    /// TableView responsible for displaying row numbers
    open lazy var lineNumberTableView: LineNumberTableView = {
        let tableView = LineNumberTableView(frame: .zero, style: .plain)
        
        tableView.specialTag = .lineView
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LineNumberCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    /// TextView responsible for displaying JSON
    open lazy var jsonTextView: JSONTextView = {
        let textView = JSONTextView()
        
        textView.specialTag = .jsonView
        textView.clickDelegate = self
        textView.delegate = self
        
        return textView
    }()
    
    /// Data source for line number view
    private var lineDataSource: [Int] = [] {
        didSet { lineNumberTableView.reloadData() }
    }
    
    /// Line number view, height of each row.
    private lazy var lineHeights: [Int: CGFloat] = [:]
    
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
                this.lineDataSource = (1 ... this.decorator.slices.count).map { $0 }
            }
        }
    }
}

public extension JSONPreview {
    /// Preview json.
    ///
    /// - Parameters:
    ///   - json: The json to be previewed
    ///   - style: Highlight style. See `HighlightStyle` for details.
    ///   - completion: Callback after data processing is completed.
    func preview(_ json: String, style: HighlightStyle = .default, completion: (() -> Void)? = nil) {
        highlightStyle = style
        
        DispatchQueue.global().async { [weak self] in
            self?.decorator = JSONDecorator.highlight(json, style: style)
            DispatchQueue.main.async { completion?() }
        }
    }
}

// MARK: - Constant

private extension JSONPreview {
    enum Tag: Int {
        /// Tag of `lineNumberTableView`
        case lineView = 222
        
        /// Tag of `jsonTextView`
        case jsonView = 111
    }
    
    enum Constant {
        /// Fixed width of `lineNumberTableView`
        static let lineWith: CGFloat = 55
    }
}

// MARK: - Config

private extension JSONPreview {
    func config() {
        addSubview(lineNumberTableView)
        addSubview(jsonTextView)
        
        // lineNumberTableView
        addLineNumberTableViewLayout()
        
        // jsonTextView
        addJSONTextViewLayout()
    }
    
    func addLineNumberTableViewLayout() {
        var constraints = [
            lineNumberTableView.widthAnchor.constraint(equalToConstant: Constant.lineWith),
            lineNumberTableView.topAnchor.constraint(equalTo: topAnchor),
            lineNumberTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        constraints.append(lineNumberTableView.leftAnchor.constraint(equalTo: {
            guard #available(iOS 11.0, *) else { return leftAnchor }
            return safeAreaLayoutGuide.leftAnchor
        }()))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addJSONTextViewLayout() {
        var constraints = [
            jsonTextView.leftAnchor.constraint(equalTo: lineNumberTableView.rightAnchor/*, constant: -1*/),
            jsonTextView.topAnchor.constraint(equalTo: lineNumberTableView.topAnchor),
            jsonTextView.bottomAnchor.constraint(equalTo: lineNumberTableView.bottomAnchor),
        ]
        
        constraints.append(jsonTextView.rightAnchor.constraint(equalTo: {
            guard #available(iOS 11.0, *) else { return rightAnchor }
            return safeAreaLayoutGuide.rightAnchor
        }()))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Calculate the line height of the line number display area
    func calculateLineHeight(at index: Int, width: CGFloat) -> CGFloat {
        let attString = decorator.slices[index].expand
        
        var tmpAtt: [NSAttributedString.Key : Any] = [:]
        
        attString.enumerateAttributes(in: NSRange(location: 0, length: attString.length)) { (values, _, _) in
            values.forEach { tmpAtt[$0] = $1 }
        }
        
        let rect = (attString.string as NSString).boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: tmpAtt,
            context: nil
        )
        
        return rect.height
    }
    
    func getLineHeight(at index: Int) -> CGFloat {
        let line = lineDataSource[index]
        
        if let height = lineHeights[line] {
            return height
        }
        
        let height = calculateLineHeight(at: line - 1, width: jsonTextView.frame.width)
        lineHeights[line] = height
        
        return height
    }
}

// MARK: - UITableViewDelegate

extension JSONPreview: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getLineHeight(at: indexPath.row)
    }
}

// MARK: - UITableViewDataSource

extension JSONPreview: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .clear
        
        cell.textLabel?.text = "\(lineDataSource[indexPath.row])"
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.font = highlightStyle.lineFont
        cell.textLabel?.textColor = highlightStyle.color.lineText
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension JSONPreview: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        
        switch scrollView.specialTag {
        case .lineView:
            jsonTextView.contentOffset = contentOffset
            
        case .jsonView:
            let y = contentOffset.y
            
            // Ignore the spring effect on the top half of the `jsonTextView`
            if y <= 0 {
                lineNumberTableView.contentOffset.y = 0
                return
            }
            
            // Ignore the spring effect on the bottom half of the `jsonTextView`
            let diff = scrollView.contentSize.height - scrollView.frame.height
            if y >= diff {
                lineNumberTableView.contentOffset.y = diff
                return
            }
            
            lineNumberTableView.contentOffset = contentOffset
            
        default:
            break
        }
    }
}

// MARK: - UITextViewDelegate

extension JSONPreview: UITextViewDelegate {}

// MARK: - JSONTextViewDelegate

extension JSONPreview: JSONTextViewDelegate {
    public func textView(_ textView: JSONTextView, didClickZoomAt pointY: CGFloat) {
        defer {
            // Need to delay a small number of seconds,
            // otherwise the modification will not take effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                guard let this = self else { return }
                
                // Synchronous Offset
                textView.contentOffset = this.lineNumberTableView.contentOffset
            }
        }
        
        let slices = decorator.slices
        
        // 1. Get the number of rows
        guard let indexPath = lineNumberTableView.indexPathForRow(at: CGPoint(x: 5, y: pointY)) else {
            return
        }
        
        let row = indexPath.row
        guard row < lineDataSource.count else { return }
        
        let tmpLineNumber = lineDataSource[row]
        
        // 1.1. Count the number of rows that are folded,
        //      and get the actual number of rows at the clicked position
        let realRow = slices.reduce(into: row) {
            if ($1.lineNumber < tmpLineNumber) && $1.foldedTimes > 0 { $0 += 1 }
        }
        
        // 2. Calculate the starting point of the replacement range
        let location = slices[0 ..< realRow].reduce(0) {
            guard $1.foldedTimes == 0 else { return $0 }
            
            return $0 + 1 /* Wrap */ + {
                switch $0.state {
                case .expand: return $0.expand.length
                case .folded: return $0.folded?.length ?? 0
                }
            }($1)
        }
        
        // 3. Get the clicked slice
        let clickSlice = slices[realRow]
        
        // 4. Perform different operations based on slice status
        switch clickSlice.state {
        
        // 4.1. Expanded state: perform folded operation
        case .expand:
            guard let folded = clickSlice.folded else { return }
            
            decorator.slices[realRow].state = .folded
            
            var isExecution = true
            var lines: [Int] = []
            var length = clickSlice.expand.length
            
            for i in realRow + 1 ..< slices.count {
                guard isExecution else { break }
                
                let _slices = slices[i]
                
                guard _slices.level >= clickSlice.level else { continue }
                
                if _slices.level == clickSlice.level { isExecution = false }
                
                // Increase the number of times being folded
                decorator.slices[i].foldedTimes += 1
                
                guard _slices.foldedTimes == 0 else { continue }
                
                // Record the line number to be hidden
                lines.append(_slices.lineNumber)
                
                // Accumulate the length of the string to be hidden
                length = length + 1 /* Wrap */ + {
                    switch _slices.state {
                    case .expand: return _slices.expand.length
                    case .folded: return _slices.folded?.length ?? 0
                    }
                }()
            }
            
            // 5. Delete the hidden line number
            var tmpDataSource = lineDataSource
            
            lines.forEach {
                guard let index = tmpDataSource.firstIndex(of: $0) else { return }
                tmpDataSource.remove(at: index)
            }
            
            lineDataSource = tmpDataSource
            
            // 6. Replacement string
            textView.textStorage.replaceCharacters(
                in: NSRange(location: location, length: length),
                with: folded
            )
            
        // 4.2. Folded state: perform expand operation
        case .folded:
            guard let folded = clickSlice.folded else { return }
            
            decorator.slices[realRow].state = .expand
            
            var isExecution = true
            var lines: [Int] = []
            
            let replaceString = NSMutableAttributedString(string: "")
            
            for i in realRow + 1 ..< slices.count {
                
                guard isExecution else { break }
                
                let _slices = slices[i]
                
                guard _slices.level >= clickSlice.level else { continue }
                
                if _slices.level == clickSlice.level { isExecution = false }
                
                // Reduce the number of folds
                decorator.slices[i].foldedTimes -= 1
                
                guard decorator.slices[i].foldedTimes == 0 else { continue }
                
                // Record the line number to be hidden
                lines.append(_slices.lineNumber)
                
                switch _slices.state {
                case .expand:
                    replaceString.append(_slices.expand)
                    replaceString.append(decorator.wrapString)
                    
                case .folded:
                    if let _folded = _slices.folded {
                        replaceString.append(_folded)
                        replaceString.append(decorator.wrapString)
                    }
                }
            }
            
            // 5. Add the line number to display
            var tmpDataSource = lineDataSource
            
            lines.forEach { (line) in
                
                let index = tmpDataSource.firstIndex { $0 > line } ?? (tmpDataSource.count)
                tmpDataSource.insert(line, at: index)
            }
            
            lineDataSource = tmpDataSource
            
            // 6. Replacement string
            replaceString.insert(decorator.wrapString, at: 0)
            replaceString.insert(clickSlice.expand, at: 0)
            
            replaceString.deleteCharacters(
                in: NSRange(location: replaceString.length - 1, length: 1)
            )
            
            textView.textStorage.replaceCharacters(
                in: NSRange(location: location, length: folded.length),
                with: replaceString
            )
        }
    }
}

// MARK: - Tools

fileprivate extension UIView {
    var specialTag: JSONPreview.Tag? {
        set {
            guard let _tag = newValue else { return }
            tag = _tag.rawValue
        }
        get { JSONPreview.Tag(rawValue: tag) }
    }
}
