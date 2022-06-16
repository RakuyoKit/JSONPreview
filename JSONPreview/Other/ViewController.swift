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
        
        previewView.delegate = self
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(previewView)
        
        var constraints: [NSLayoutConstraint] = [
//            previewView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
        
        constraints.append(previewView.topAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.topAnchor
            } else {
                return view.topAnchor
            }
        }()))
        
        constraints.append(previewView.bottomAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.bottomAnchor
            } else {
                return view.bottomAnchor
            }
        }()))
        
        constraints.append(previewView.leadingAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.leadingAnchor
            } else {
                return view.leadingAnchor
            }
        }()))
        
        constraints.append(previewView.trailingAnchor.constraint(equalTo: {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.trailingAnchor
            } else {
                return view.trailingAnchor
            }
        }()))
        
        NSLayoutConstraint.activate(constraints)
        
        let json = 
        """
        [
            [],
            [],
            {
                "string" : "string",
                "int" : 1024,
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
                    1024,
                    -50,
                    true,
                    false,
                    null,
                    "http://www.apple.com",
                    "https:\\/\\/www.github.com",
                    "stackoverflow.com",
                    "172.168.0.1",
                    "aaa.com.bd",
                    "test-aaa.com.bd",
                    "",
                    [],
                    {},
                ]
            },
            {
                "exponential_value": [
                    1024e+23,
                    -25e+23,
                    -25e-23,
                    2.54e23,
                    3.1415926E+23,
                    3.1415926E-23,
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
            {123456}
        ]
        """
        
        
        let start = Date().timeIntervalSince1970
        print("will display json")
        
        previewView.preview(json, style: .default) {
            let end = Date().timeIntervalSince1970
            let timeConsuming = end - start
            
            print("did display json at: \(timeConsuming)")
        }
    }
}

// MARK: - UITextViewDelegate

extension ViewController: JSONPreviewDelegate {
    func jsonPreview(view: JSONPreview, didClickURL url: URL, on textView: UITextView) -> Bool {
        print(url)
        
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)
        
        return false
    }
}
