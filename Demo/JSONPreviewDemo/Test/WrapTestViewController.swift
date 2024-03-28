//
//  WrapTestViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/27.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

final class WrapTestViewController: UIViewController {
    private lazy var stackView: UIStackView = {
        let _view = UIStackView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.backgroundColor = .red
        _view.axis = .horizontal
        _view.distribution = .fill
        _view.alignment = .fill
        return _view
    }()
    
    private lazy var lineView: UIView = {
        let _view = UIView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.backgroundColor = .green
        return _view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let _view = UIScrollView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.backgroundColor = .cyan
        return _view
    }()
    
    private lazy var textView: UITextView = {
        let _view = UITextView()
        _view.backgroundColor = .brown
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.font = UIFont.systemFont(ofSize: 20)
        _view.text = testText
        _view.isScrollEnabled = false
#if !os(tvOS)
        _view.isEditable = false
#endif
        return _view
    }()
    
    private lazy var testText = """
        // MARK: - Life cycle
        
        extension WrapTestViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
        
                title = "Wrap Test"
        
                view.backgroundColor = .white
        
                view.addSubview(stackView)
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: view.topAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
        
                stackView.addArrangedSubview(lineView)
                NSLayoutConstraint.activate([
                    lineView.widthAnchor.constraint(equalToConstant: 55)
                ])
        
                stackView.addArrangedSubview(textView)
            }
        }
        
        // MARK: - Life cycle
                
        extension WrapTestViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                
                title = "Wrap Test"
                
                view.backgroundColor = .white
                
                view.addSubview(stackView)
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: view.topAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
                
                stackView.addArrangedSubview(lineView)
                NSLayoutConstraint.activate([
                    lineView.widthAnchor.constraint(equalToConstant: 55)
                ])
                
                stackView.addArrangedSubview(textView)
            }
        }
        
        // MARK: - Life cycle
                
        extension WrapTestViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                
                title = "Wrap Test"
                
                view.backgroundColor = .white
                
                view.addSubview(stackView)
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: view.topAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
                
                stackView.addArrangedSubview(lineView)
                NSLayoutConstraint.activate([
                    lineView.widthAnchor.constraint(equalToConstant: 55)
                ])
                
                stackView.addArrangedSubview(textView)
            }
        }
        """
}

// MARK: - Life cycle

extension WrapTestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wrap Test"
        
        view.backgroundColor = .white
        
//        withoutStackView()
        withStackView()
    }
}

// MARK: -

private extension WrapTestViewController {
    func withoutStackView() {
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func withStackView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(lineView)
        stackView.addArrangedSubview(scrollView)
        scrollView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            lineView.widthAnchor.constraint(equalToConstant: 55)
        ])
        
        let size = calculateSize(with: .init(string: testText))
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: size.height),
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: size.width),
        ])
    }
}

private extension WrapTestViewController {
    /// Calculate the size of a rich text string in a container
    func calculateSize(
        with attributedString: NSMutableAttributedString,
        width: CGFloat = .greatestFiniteMagnitude,
        height: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        let size = CGSize(width: width, height: height)
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        layoutManager.glyphRange(
            forBoundingRect: CGRect(origin: .zero, size: size),
            in: textContainer
        )
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)
        
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size
    }
}
