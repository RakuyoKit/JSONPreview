//
//  WrapExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/28.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

final class WrapExampleViewController: BaseJSONPreviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wrap example"
        
        previewView.highlightStyle = .mariana
        
        configBarButtonItem()
        
        addPreviewViewLayout()
        
        preview()
    }
}

// MARK: -

private extension WrapExampleViewController {
    func addPreviewViewLayout() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func preview() {
#if os(visionOS)
        let json = ExampleJSON.veryLongText
#else
        let json = ExampleJSON.mostComprehensive
#endif
        previewView.preview(json)
    }
}

private extension WrapExampleViewController {
    var barButtonTitle: String {
        previewView.automaticWrapEnabled ? "not wrap" : "auto wrap"
    }
    
    func configBarButtonItem() {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        
        button.setTitle(barButtonTitle, for: .normal)
        
        button.addTarget(self, action: #selector(barButtonDidClick(_:)), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc
    func barButtonDidClick(_ button: UIButton) {
        previewView.automaticWrapEnabled.toggle()
        button.setTitle(barButtonTitle, for: .normal)
    }
}
