//
//  TVOSWrapExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/28.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

// MARK: - TVOSWrapExampleViewController

final class TVOSWrapExampleViewController: BaseJSONPreviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Wrap example"
        
        previewView.highlightStyle = .mariana
        previewView.automaticWrapEnabled = false
        
        addPreviewViewLayout()
        
        previewView.preview(ExampleJSON.veryLongText)
    }
}

// MARK: -

extension TVOSWrapExampleViewController {
    private func addPreviewViewLayout() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
