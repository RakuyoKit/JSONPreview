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
            previewView.heightAnchor.constraint(equalToConstant: 300),
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
                "string": "This is a string that has some \\"quotes\\" inside it!"
            },
            {
                "key_1" : "string",
                "key_2" : 3.1415926,
                "key_3" : -50,
                "key_4" : [],
                "key_5" : {},
                "key_6" : {
                    "key_6_1" : null,
                    "key_6_2" : [
                        "stackoverflow.com",
                        "http://www.apple.com",
                        "array_1",
                        3.1415926,
                        -50,
                        true,
                        false,
                        null,
                        {},
                        {
                            "some_key" : "some_value"
                        }
                    ],
                    "key_6_3" : {
                        "bool_1" : true,
                        "bool_2" : false,
                        "empty_string" : "",
                        "url" : "172.168.0.1",
                        "test_url_escaping" : "https:\\/\\/www.github.com"
                    }
                }
            },
            {
                "some_key" : "A very very very very very very very very very very long string."
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
