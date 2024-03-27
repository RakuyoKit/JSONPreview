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
    
    private lazy var textView: UITextView = {
        let _view = UITextView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        _view.font = UIFont.systemFont(ofSize: 20)
        _view.text = """
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
        
        return _view
    }()
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
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
