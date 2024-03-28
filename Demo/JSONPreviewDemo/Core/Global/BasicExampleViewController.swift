//
//  BasicExampleViewController.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

final class BasicExampleViewController: BaseJSONPreviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic example"
        
        addPreviewViewLayout()
        
        preview()
    }
}

// MARK: -

private extension BasicExampleViewController {
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
        let json = ExampleJSON.mostComprehensive
        
        print("will display json")
        let start = Date().timeIntervalSince1970
        
        previewView.preview(json) { _ in
            let end = Date().timeIntervalSince1970
            print("did display json at: \(end - start)")
        }
    }
}
