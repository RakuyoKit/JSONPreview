//
//  BaseJSONPreviewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

#if !os(tvOS)
import SafariServices
#endif

import JSONPreview

class BaseJSONPreviewController: UIViewController {
    lazy var previewView = JSONPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
#if os(tvOS)
        // Because on tvOS, the line number cannot be aligned with the json line,
        // so the line number is hidden by default.
        previewView.isHiddenLineNumber = true
#else
        previewView.delegate = self
#endif
        
        view.addSubview(previewView)
    }
}

#if !os(tvOS)
// MARK: - UITextViewDelegate

extension BaseJSONPreviewController: JSONPreviewDelegate {
    func jsonPreview(_ view: JSONPreview, didClickURL url: URL, on textView: UITextView) -> Bool {
        print(url)
        
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)
        
        return false
    }
}
#endif
