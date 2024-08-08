//
//  BasicExampleViewController.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

// MARK: - BasicExampleViewController

final class BasicExampleViewController: BaseJSONPreviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic example"
        
        addPreviewViewLayout()
        
        preview()
    }
}

// MARK: -

extension BasicExampleViewController {
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
        let json = ExampleJSON.mostComprehensive
        
        Log.debug("will display json")
        let start = Date().timeIntervalSince1970
        
        previewView.preview(json) { _ in
            let end = Date().timeIntervalSince1970
            Log.debug("did display json at: \(end - start)")
        }
    }
}
