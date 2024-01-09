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
    
    deinit {
        if !isOriginalGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// View skeleton, containing all subviews
    open lazy var skeletonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
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
    
    public var contentSize: CGSize { jsonTextView.contentSize }
    
    public var scrollsToTop: Bool {
        get { jsonTextView.scrollsToTop }
        set { jsonTextView.scrollsToTop = newValue }
    }
    
    /// Whether to hide the line number view
    public var isHiddenLineNumber: Bool {
        get { lineNumberTableView.isHidden }
        set { lineNumberTableView.isHidden = newValue }
    }
    
    /// delegate for `JSONPreview`.
    public weak var delegate: JSONPreviewDelegate? = nil
    
    /// Highlight style
    public lazy var highlightStyle: HighlightStyle = .`default` {
        didSet { updateHighlightStyle() }
    }
    
    /// JSON Decoder.
    private lazy var decorator: JSONDecorator? = nil
    
    /// Record the direction of the last equipment.
    private lazy var lastOrientation: Orientation = .unknow
    
    // Record previous property values
    private lazy var isOriginalGeneratingDeviceOrientationNotifications = UIDevice.current.isGeneratingDeviceOrientationNotifications
    
    /// Line Number Height Manager.
    private lazy var lineNumberHeightManager = LineNumberHeightManager()
    
    /// Data source for line number view
    private var lineDataSource: [Int] = [] {
        didSet { lineNumberTableView.reloadData() }
    }
}

public extension JSONPreview {
    typealias Completion = (JSONDecorator?) -> Void
    
    /// Preview json.
    ///
    /// If you want to use it in a list, such as a `UITableView`, then this method can only
    /// be called when the JSON is displayed for the first time.
    ///
    /// You should obtain and hold the JSONDecorator object from completion, and then call the 
    /// `update(with:)` method to set the content when the Cell is reused.
    ///
    /// - Parameters:
    ///   - json: The json to be previewed
    ///   - initialState: The initial state of the rendering result. The initial state of all nodes will be consistent with this value.
    ///   - completion: Callback after rendering is completed.
    func preview(
        _ json: String,
        initialState: JSONSlice.State = .`default`,
        completion: Completion? = nil
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let this = self else { return }
            
            let decorator = JSONDecorator.highlight(
                json,
                style: this.highlightStyle,
                initialState: initialState
            )
            
            DispatchQueue.main.async { [weak this] in
                this?.setJSONDecoratort(decorator, completion: completion)
            }
        }
    }
    
    /// Update JSON content.
    ///
    /// If you do not want to destroy the existing JSON folding state,
    /// you need to do some processing on the JSON slices, such as re-rendering the style.
    /// Then you should call this method to update after processing.
    ///
    /// - Parameters:
    ///   - decorator: JSON Decoder.
    ///   - completion: Callback when rendering is complete. Always callback on the main thread.
    func update(with decorator: JSONDecorator?, completion: Completion? = nil) {
        setJSONDecoratort(decorator, completion: completion)
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
        addSubview(skeletonStackView)
        skeletonStackView.addArrangedSubview(lineNumberTableView)
        skeletonStackView.addArrangedSubview(jsonTextView)
        
        // skeletonStackView
        addSkeletonStackViewLayout()
        
        // lineNumberTableView
        addLineNumberTableViewLayout()
        
        // Listening to device rotation in preparation for recalculating cell height
        listeningDeviceRotation()
        
        updateHighlightStyle()
        
        jsonTextView.textContainerInset = UIEdgeInsets(
            top: 0, left: 10, bottom: 0, right: 10
        )
    }
    
    func addSkeletonStackViewLayout() {
        skeletonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            skeletonStackView.topAnchor.constraint(equalTo: topAnchor),
            skeletonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        constraints.append(skeletonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor))
        
        constraints.append(skeletonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addLineNumberTableViewLayout() {
        lineNumberTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineNumberTableView.widthAnchor.constraint(equalToConstant: Constant.lineWith),
        ])
    }
    
    func listeningDeviceRotation() {
        if !isOriginalGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

private extension JSONPreview {
    @objc
    func handleDeviceOrientationChange(_ notification: NSNotification) {
        switch UIDevice.current.orientation {
        case .portrait:
            lastOrientation = .portrait
            lineNumberTableView.reloadData()
            
        case .landscapeLeft, .landscapeRight:
            lastOrientation = .landscape
            lineNumberTableView.reloadData()
            
        default:
            break
        }
    }
    
    func getLineHeight(at index: Int) -> CGFloat {
        guard let slices = decorator?.slices else { return 0 }
        
        let line = lineDataSource[index]
        let slice = slices[line - 1]
        
        if let height = lineNumberHeightManager.height(at: index, orientation: lastOrientation, state: slice.state) {
            return height
        }
        
        let width = jsonTextView.frame.width - { $0.left + $0.right }(jsonTextView.textContainerInset)
        let height = lineNumberHeightManager.calculateHeight(with: slice, width: width)
        lineNumberHeightManager.cache(height, at: index, orientation: lastOrientation, state: slice.state)
        
        return height
    }
    
    func updateHighlightStyle() {
        let colorStyle = highlightStyle.color
        lineNumberTableView.backgroundColor = colorStyle.lineBackground
        jsonTextView.backgroundColor = colorStyle.jsonBackground
        skeletonStackView.backgroundColor = colorStyle.jsonBackground
    }
    
    func setJSONDecoratort(_ decorator: JSONDecorator?, completion: Completion?) {
        self.decorator = decorator
        
        guard let _decorator = decorator else {
            DispatchQueue.main.async { completion?(nil) }
            return
        }
        
        let attributedText = AttributedString(string: "")
        var lines: [Int] = []
        
        var foldedLevel: Int? = nil
        for (index, slice) in _decorator.slices.enumerated() {
            if let _level = foldedLevel {
                if slice.level > _level { continue }
                
                if slice.level == _level {
                    foldedLevel = nil
                    continue
                }
            }
            
            switch slice.state {
            case .expand:
                attributedText.append(slice.expand)
                attributedText.append(_decorator.wrapString)
                
                lines.append(index + 1)
                
            case .folded:
                guard let _folded = slice.folded else { continue }
                
                foldedLevel = slice.level
                
                attributedText.append(_folded)
                attributedText.append(_decorator.wrapString)
                
                lines.append(index + 1)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            defer { completion?(_decorator) }
            
            this.jsonTextView.attributedText = attributedText
            this.lineDataSource = lines
        }
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

extension JSONPreview: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard 
            let _delegate = delegate,
            let openingURL = url.absoluteString.validURL?.openingURL
        else {
            return true
        }
        
        return _delegate.jsonPreview(self, didClickURL: openingURL, on: textView)
    }
}

// MARK: - JSONTextViewDelegate

extension JSONPreview: JSONTextViewDelegate {
    public func textView(_ textView: JSONTextView, didClickZoomAt pointY: CGFloat) {
        guard let decorator = decorator else { return }
        
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
            
            defer {
                delegate?.jsonPreview(self, didChangeSliceState: slices[realRow], decorator: decorator)
            }
            
            decorator.slices[realRow].state = .folded
            
            var isExecution = true
            var lines: [Int] = []
            var length = clickSlice.expand.length
            
            for i in (realRow + 1) ..< slices.count {
                guard isExecution else { break }
                
                let _slice = slices[i]
                
                guard _slice.level >= clickSlice.level else { continue }
                
                if _slice.level == clickSlice.level { isExecution = false }
                
                // Increase the number of times being folded
                decorator.slices[i].foldedTimes += 1
                
                guard _slice.foldedTimes == 0 else { continue }
                
                // Record the line number to be hidden
                lines.append(_slice.lineNumber)
                
                // Accumulate the length of the string to be hidden
                length = length + 1 /* Wrap */ + {
                    switch _slice.state {
                    case .expand: return _slice.expand.length
                    case .folded: return _slice.folded?.length ?? 0
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
            
            defer {
                delegate?.jsonPreview(self, didChangeSliceState: slices[realRow], decorator: decorator)
            }
            
            decorator.slices[realRow].state = .expand
            
            var isExecution = true
            var lines: [Int] = []
            
            let replaceString = AttributedString(string: "")
            
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
