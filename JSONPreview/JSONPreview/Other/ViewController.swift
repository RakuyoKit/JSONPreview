//
//  ViewController.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    lazy var previewView = JSONPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.jsonTextView.delegate = self
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(previewView)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            previewView.heightAnchor.constraint(equalToConstant: 500),
            previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
        
        constraints.append(previewView.leftAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.leftAnchor
            } else {
                return view.leftAnchor
            }
        }()))
        
        constraints.append(previewView.rightAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.rightAnchor
            } else {
                return view.rightAnchor
            }
        }()))
        
        NSLayoutConstraint.activate(constraints)
        
        let json = """
        [
            {
                "string" : "string",
                "float" : 3.1415926,
                "negative_numbers" : -50,
                "bool_true" : true,
                "bool_false" : false,
                "null" : null,
                "url" : "http://www.apple.com",
                "url_with_escape" : "https:\\/\\/www.github.com",
                "url_without_protocol" : "stackoverflow.com",
                "unsupported_url" : "172.168.0.1",
                "empty_string" : "",
                "empty_array" : [],
                "empty_object" : {},
            },
            {
                "effects_in_array" : [
                    "string",
                    3.1415926,
                    -50,
                    true,
                    false,
                    null,
                    "http://www.apple.com",
                    "https:\\/\\/www.github.com",
                    "stackoverflow.com",
                    "172.168.0.1",
                    "",
                    [],
                    {},
                ]
            },
            {
                "quotes_string": "This is a string that has some \\"quotes\\" inside it!",
                "very_long_value" : "A very very very very very very very very very very very very long string."
            },
            {
                "nested" : {
                    "object" : {
                        "array" : [
                            "string",
                            [
                                {
                                    "key" : "value"
                                }
                            ]
                        ]
                    }
                }
            },
            {
                {123456}
            }
        ]
        """
        
        previewView.preview(json, style: .default)
    }
}

// MARK: - UITextViewDelegate

extension ViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        var _url = URL
        
        if let scheme = URL.scheme {
            guard scheme == "http" || scheme == "https" else { return true }
            
        } else {
            
            guard let newURL = Foundation.URL(string: "http://" + _url.absoluteString) else {
                return true
            }
            
            _url = newURL
        }
        
        let safari = SFSafariViewController(url: _url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)
        
        return false
    }
}
