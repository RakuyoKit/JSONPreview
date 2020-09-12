//
//  ViewController.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var previewView = JSONPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.frame.size.width = view.frame.width - 20
        previewView.frame.size.height = 700
        previewView.center = view.center
        
        view.addSubview(previewView)
        
        let json = """
        {
            "key_1" : "string",
            "key_2" : 3.1415926,
            "key_3" : -50,
            "key_4" : [],
            "key_5" : {},
            "key_6" : {
                "key_6_1" : null,
                "key_6_2" : [
                    "value_1",
                    "value_2"
                ],
                "key_6_3" : {
                    "bool_1" : true,
                    "bool_2" : false,
                    "empty_string" : ""
                }
            }
        },
        [
            "array_1",
            3.1415926,
            -50,
            true,
            false,
            null
            {},
            {
                "some_key" : "some_value"
            }
        ],
        {
            "key_1" : "string",
            "key_2" : 3.1415926,
            "key_3" : -50,
            "key_4" : [],
            "key_5" : {},
            "key_6" : {
                "key_6_1" : null,
                "key_6_2" : [
                    "value_1",
                    "value_2"
                ],
                "key_6_3" : {
                    "bool_1" : true,
                    "bool_2" : false,
                    "empty_string" : ""
                }
            }
        },
        [
            "array_1",
            3.1415926,
            -50,
            true,
            false,
            null
            {},
            {
                "some_key" : "some_value"
            }
        ]
        """
        
        previewView.preview(json, style: .mariana)
    }
}
