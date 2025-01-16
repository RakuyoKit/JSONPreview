//
//  InitialFoldedExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

// MARK: - InitialFoldedExampleViewController

final class InitialFoldedExampleViewController: BaseJSONPreviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Initial Folded example"
        
        addPreviewViewLayout()
        
        preview()
    }
}

// MARK: -

extension InitialFoldedExampleViewController {
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
        let json = ExampleJSON.legalJson
        
        Log.debug("will display json")
        let start = Date().timeIntervalSince1970
        
        previewView.preview(json, initialState: .folded) { _ in
            let end = Date().timeIntervalSince1970
            Log.debug("did display json at: \(end - start)")
        }
    }
}
