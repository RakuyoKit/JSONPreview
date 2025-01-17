//
//  WrapExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/28.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

// MARK: - WrapExampleViewController

final class WrapExampleViewController: BaseJSONPreviewController {
    override var automaticWrapEnabled: Bool { false }
    
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

extension WrapExampleViewController {
    private func addPreviewViewLayout() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func preview() {
        #if os(visionOS)
        let json = ExampleJSON.veryLongText
        #else
        let json = ExampleJSON.mostComprehensive
        #endif
        previewView.preview(json)
    }
}

extension WrapExampleViewController {
    private var barButtonTitle: String {
        previewView.automaticWrapEnabled ? "not wrap" : "auto wrap"
    }
    
    private func configBarButtonItem() {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        
        button.setTitle(barButtonTitle, for: .normal)
        
        button.addTarget(self, action: #selector(barButtonDidClick(_:)), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc
    private func barButtonDidClick(_ button: UIButton) {
        previewView.automaticWrapEnabled.toggle()
        button.setTitle(barButtonTitle, for: .normal)
    }
}
