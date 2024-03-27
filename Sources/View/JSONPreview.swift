//
//  JSONPreview.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

open class JSONPreview: UIView {
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
        /*
         Because there is currently no way to build a `.plain` style UITableView with
         no spacing between Cells on visionOS.
         
         The spacing between Cells will cause the line numbers and json lines to
         not correspond one to one, which will affect the folding and expanding functions.
         
         So you can only change the style to .grouped to construct a UITableView object
         with no spacing between Cells.
         */
        let tableView = LineNumberTableView(frame: .zero, style: .grouped)
        tableView.specialTag = .lineView
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LineNumberCell.self, forCellReuseIdentifier: "cell")
        
#if os(tvOS)
        tableView.isHidden = true
#endif
        return tableView
    }()
    
    /// TextView responsible for displaying JSON
    open lazy var jsonTextView: JSONTextView = {
        let textView = JSONTextView()
        textView.specialTag = .jsonView
        
#if !os(tvOS)
        textView.delegate = self
        textView.clickDelegate = self
#endif
        return textView
    }()
    
#if !os(tvOS)
    /// delegate for `JSONPreview`.
    public weak var delegate: JSONPreviewDelegate? = nil
#endif
    
    /// Highlight style
    public lazy var highlightStyle: HighlightStyle = .`default` {
        didSet { updateHighlightStyle() }
    }
    
    /// JSON Decoder.
    private lazy var decorator: JSONDecorator? = nil
    
    /// Record the direction of the last equipment.
    private lazy var lastOrientation: Orientation = .unknow
    
#if !os(visionOS) && !os(tvOS)
    /// Record previous property values
    private lazy var isGeneratingOrientationNotifications: Bool = {
        UIDevice.current.isGeneratingDeviceOrientationNotifications
    }()
#endif
    
    /// Line Number Height Manager.
    private lazy var lineNumberHeightManager = LineNumberHeightManager()
    
    /// Data source for line number view
    private var lineDataSource: [Int] = [] {
        didSet { lineNumberTableView.reloadData() }
    }
    
    /// The row number where the search results are stored is used to
    /// optimize operations when clearing search results.
    ///
    /// Currently, this object stores the position index after json is fully expanded.
    private lazy var searchResultIndex: [Int] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    deinit {
#if !os(visionOS) && !os(tvOS)
        if !isGeneratingOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
#endif
    }
}

public extension JSONPreview {
    var contentSize: CGSize { jsonTextView.contentSize }
    
    /// Whether to hide the line number view
    var isHiddenLineNumber: Bool {
        get { lineNumberTableView.isHidden }
        set { lineNumberTableView.isHidden = newValue }
    }
    
    var bounces: Bool {
        get { jsonTextView.isHidden }
        set { jsonTextView.isHidden = newValue }
    }
    
    var showsHorizontalScrollIndicator: Bool {
        get { jsonTextView.showsHorizontalScrollIndicator }
        set { jsonTextView.showsHorizontalScrollIndicator = newValue }
    }
    
    var showsVerticalScrollIndicator: Bool {
        get { jsonTextView.showsVerticalScrollIndicator }
        set { jsonTextView.showsVerticalScrollIndicator = newValue }
    }
    
#if !os(tvOS)
    var scrollsToTop: Bool {
        get { jsonTextView.scrollsToTop }
        set { jsonTextView.scrollsToTop = newValue }
    }
#endif
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
    ///   - initialState: The initial state of the rendering result.
    ///                   The initial state of all nodes will be consistent with this value.
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

public extension JSONPreview {
    typealias SearchCompletion = (_ index: [Int], JSONDecorator?) -> Void
    
    /// Search the currently rendered json for target content.
    ///
    /// - Parameters:
    ///   - content: What to search for
    ///   - completion: Returns the line number where the search results are located.
    ///                 The subscript starts from 0 and is the index after the json is fully expanded.
    func search(_ content: String, completion: SearchCompletion? = nil) {
        guard let _decorator = decorator else {
            completion?([], decorator)
            return
        }
        
        removeSearchStyle()
        
        let attrs: [NSAttributedString.Key: Any] = [
            .backgroundColor: highlightStyle.color.searchHitBackground,
            .font: highlightStyle.boldOfJSONFont()
        ].compactMapValues { $0 }
        
        let processSlice: (AttributedString) -> Bool = { (attributedString) in
            let ranges = attributedString.string.findNSRanges(of: content)
            guard !ranges.isEmpty else { return false }
            
            ranges.forEach {
                attributedString.addAttributes(attrs, range: $0)
            }
            return true
        }
        
        let indexs: [Int] = _decorator.slices.enumerated().compactMap {
            var appendLine = processSlice($1.expand)
            
            if let foldedString = $1.folded, processSlice(foldedString) {
                appendLine = true
            }
            
            return appendLine ? $0 : nil
        }
        
        defer {
            searchResultIndex = indexs
        }
        
        if indexs.isEmpty {
            completion?([], _decorator)
        } else {
            assembleAttributedText(with: _decorator) {
                completion?(indexs, $0)
            }
        }
    }
    
    /// Clear all search result styles.
    func removeSearchStyle(completion: Completion? = nil) {
        guard
            let _decorator = decorator,
            !searchResultIndex.isEmpty
        else {
            completion?(decorator)
            return
        }
        
        defer {
            searchResultIndex = []
        }
        
        for line in searchResultIndex {
            guard _decorator.slices.indices.contains(line) else { continue }
            let slice = _decorator.slices[line]
            
            let range = NSRange(location: 0, length: slice.expand.length)
            
            let attributedStrings = [slice.expand, slice.folded].compactMap { $0 }
            
            attributedStrings.forEach {
                $0.removeAttribute(.backgroundColor, range: range)
            }
            
            if highlightStyle.isBoldedSearchResult {
                let font = highlightStyle.jsonFont
                attributedStrings.forEach {
                    $0.addAttribute(.font, value: font, range: range)
                }
            }
        }
        
        assembleAttributedText(with: _decorator, completion: completion)
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
        static let lineWith: CGFloat = {
            let _width: CGFloat = 55
#if os(visionOS)
            /*
             On visionOS, there is a gap on the left and right sides of the Cell that
             cannot be eliminated for the time being.
             
             So we need to increase the width so that the line number text can be fully displayed.
             */
            return _width + 10
#else
            return _width
#endif
        }()
    }
}

// MARK: - Config

private extension JSONPreview {
    func config() {
        addSubview(skeletonStackView)
        skeletonStackView.addArrangedSubview(lineNumberTableView)
        skeletonStackView.addArrangedSubview(jsonTextView)
        
        addSkeletonStackViewLayout()
        addLineNumberTableViewLayout()
        
#if !os(visionOS) && !os(tvOS)
        // Listening to device rotation in preparation for recalculating cell height
        listeningDeviceRotation()
#endif
        
        updateHighlightStyle()
        
        jsonTextView.textContainerInset = UIEdgeInsets(
            top: 0, left: 10, bottom: 0, right: 10
        )
    }
    
    func addSkeletonStackViewLayout() {
        skeletonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skeletonStackView.topAnchor.constraint(equalTo: topAnchor),
            skeletonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            skeletonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            skeletonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func addLineNumberTableViewLayout() {
        lineNumberTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineNumberTableView.widthAnchor.constraint(equalToConstant: Constant.lineWith),
        ])
    }
}

private extension JSONPreview {
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
        
        assembleAttributedText(with: _decorator, completion: completion)
    }
    
    func assembleAttributedText(with decorator: JSONDecorator, completion: Completion?) {
        let attributedText = AttributedString(string: "")
        var lines: [Int] = []
        
        var foldedLevel: Int? = nil
        for (index, slice) in decorator.slices.enumerated() {
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
                attributedText.append(decorator.wrapString)
                
                lines.append(index + 1)
                
            case .folded:
                guard let _folded = slice.folded else { continue }
                
                foldedLevel = slice.level
                
                attributedText.append(_folded)
                attributedText.append(decorator.wrapString)
                
                lines.append(index + 1)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            defer { completion?(decorator) }
            
            this.jsonTextView.attributedText = attributedText
            this.lineDataSource = lines
            
            this.jsonTextView.contentSize.width = 1000
        }
    }
    
#if !os(tvOS)
    func handleZoomClick(at realRow: Int) {
        guard let slices = decorator?.slices else { return }
        
        // Calculate the starting point of the replacement range
        let calculateLocation: () -> Int = {
            slices[0 ..< realRow].reduce(0) {
                guard $1.foldedTimes == 0 else { return $0 }
                
                return $0 + 1 /* Wrap */ + {
                    switch $0.state {
                    case .expand: return $0.expand.length
                    case .folded: return $0.folded?.length ?? 0
                    }
                }($1)
            }
        }
        
        let clickSlice = slices[realRow]
        
        switch clickSlice.state {
        case .expand:
            handleExpandSliceDidClick(
                clickSlice: clickSlice,
                realRow: realRow,
                location: calculateLocation
            )
            
        case .folded:
            handleFoldedSliceDidClick(
                clickSlice: clickSlice,
                realRow: realRow,
                location: calculateLocation
            )
        }
    }
    
    func handleExpandSliceDidClick(clickSlice: JSONSlice, realRow: Int, location: () -> Int) {
        guard
            let decorator = decorator,
            let folded = clickSlice.folded
        else {
            return
        }
        
        let slices = decorator.slices
        
        defer {
            delegate?.jsonPreview(self, didChangeSliceState: slices[realRow], decorator: decorator)
        }
        
        decorator.slices[realRow].state = .folded
        
        var isExecution = true
        var lines: [Int] = []
        var length = clickSlice.expand.length
        
        for index in (realRow + 1) ..< slices.count {
            guard isExecution else { break }
            
            let _slice = slices[index]
            
            guard _slice.level >= clickSlice.level else { continue }
            
            if _slice.level == clickSlice.level { isExecution = false }
            
            // Increase the number of times being folded
            decorator.slices[index].foldedTimes += 1
            
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
        
        // Delete the hidden line number
        var tmpDataSource = lineDataSource
        
        lines.forEach {
            guard let index = tmpDataSource.firstIndex(of: $0) else { return }
            tmpDataSource.remove(at: index)
        }
        
        lineDataSource = tmpDataSource
        
        // Replacement string
        jsonTextView.textStorage.replaceCharacters(
            in: NSRange(location: location(), length: length),
            with: folded
        )
    }
    
    func handleFoldedSliceDidClick(clickSlice: JSONSlice, realRow: Int, location: () -> Int) {
        guard
            let decorator = decorator,
            let folded = clickSlice.folded
        else {
            return
        }
        
        let slices = decorator.slices
        
        defer {
            delegate?.jsonPreview(self, didChangeSliceState: slices[realRow], decorator: decorator)
        }
        
        decorator.slices[realRow].state = .expand
        
        var isExecution = true
        var lines: [Int] = []
        
        let replaceString = AttributedString(string: "")
        
        for index in realRow + 1 ..< slices.count {
            guard isExecution else { break }
            
            let _slices = slices[index]
            
            guard _slices.level >= clickSlice.level else { continue }
            
            if _slices.level == clickSlice.level { isExecution = false }
            
            // Reduce the number of folds
            decorator.slices[index].foldedTimes -= 1
            
            guard decorator.slices[index].foldedTimes == 0 else { continue }
            
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
        
        // Add the line number to display
        var tmpDataSource = lineDataSource
        
        lines.forEach { (line) in
            let index = tmpDataSource.firstIndex { $0 > line } ?? (tmpDataSource.count)
            tmpDataSource.insert(line, at: index)
        }
        
        lineDataSource = tmpDataSource
        
        // Replacement string
        replaceString.insert(decorator.wrapString, at: 0)
        replaceString.insert(clickSlice.expand, at: 0)
        
        replaceString.deleteCharacters(
            in: NSRange(location: replaceString.length - 1, length: 1)
        )
        
        jsonTextView.textStorage.replaceCharacters(
            in: NSRange(location: location(), length: folded.length),
            with: replaceString
        )
    }
    
#if !os(visionOS)
    func listeningDeviceRotation() {
        if !isGeneratingOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeviceOrientationChange(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc
    func handleDeviceOrientationChange(_ notification: Notification) {
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
#endif
    
#endif
}

// MARK: - UITableViewDelegate

extension JSONPreview: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getLineHeight(at: indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
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
        let y = scrollView.contentOffset.y
        
        switch scrollView.specialTag {
        case .lineView:
            jsonTextView.contentOffset.y = y
            
        case .jsonView:
            lineNumberTableView.contentOffset.y = y
            
        default:
            break
        }
    }
}

#if !os(tvOS)

// MARK: - UITextViewDelegate

extension JSONPreview: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
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
        
        let point: CGPoint = {
            let x: CGFloat = {
                let minX: CGFloat = 5
#if os(visionOS)
                /*
                 On visionOS, there is a gap on the left and right sides of the Cell that
                 cannot be eliminated for the time being.
                 
                 So we need to increase the `x` value to get the corresponding Cell.
                 */
                return minX + 15
#else
                return minX
#endif
            }()
            return CGPoint(x: x, y: pointY)
        }()
        
        // 1. Get the number of rows
        guard let indexPath = lineNumberTableView.indexPathForRow(at: point) else {
            return
        }
        
        let row = indexPath.row
        guard row < lineDataSource.count else { return }
        
        let tmpLineNumber = lineDataSource[row]
        
        // 2. Count the number of rows that are folded,
        //    and get the actual number of rows at the clicked position
        let realRow = decorator.slices.reduce(into: row) {
            if ($1.lineNumber < tmpLineNumber) && $1.foldedTimes > 0 { $0 += 1 }
        }
        
        // 3. Get the clicked slice and perform different operations based on slice status
        handleZoomClick(at: realRow)
    }
}
#endif

// MARK: - Tools

fileprivate extension UIView {
    var specialTag: JSONPreview.Tag? {
        get { JSONPreview.Tag(rawValue: tag) }
        set {
            guard let _tag = newValue else { return }
            tag = _tag.rawValue
        }
    }
}
