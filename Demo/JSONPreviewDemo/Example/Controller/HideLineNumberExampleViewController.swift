//
//  HideLineNumberExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import SafariServices

import JSONPreview

class HideLineNumberExampleViewController: BaseJSONPreviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Hide Line Number"
        
        previewView.isHiddenLineNumber = true
        
        addPreviewViewLayout()
        
        preview()
    }
}

// MARK: -

private extension HideLineNumberExampleViewController {
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
        
        previewView.preview(json, initialState: .folded) {
            let end = Date().timeIntervalSince1970
            print("did display json at: \(end - start)")
        }
    }
}
