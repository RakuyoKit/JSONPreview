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

// MARK: - BaseJSONPreviewController

class BaseJSONPreviewController: UIViewController {
    lazy var previewView = JSONPreview(automaticWrapEnabled: automaticWrapEnabled)
    
    var automaticWrapEnabled: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = {
            guard #available(iOS 13.0, *) else { return .white }
            return .systemGroupedBackground
        }()
        
        #if !os(tvOS)
        previewView.delegate = self
        #endif
        
        view.addSubview(previewView)
    }
}

#if !os(tvOS)

// MARK: - UITextViewDelegate

extension BaseJSONPreviewController: JSONPreviewDelegate {
    func jsonPreview(_: JSONPreview, didClickURL url: URL, on _: UITextView) -> Bool {
        Log.debug(url)
        
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)
        
        return false
    }
}
#endif
