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
        
        previewView.highlightStyle = .mariana
        
        previewView.frame.size.width = view.frame.width - 20
        previewView.frame.size.height = 700
        previewView.center = view.center
        
        view.addSubview(previewView)
        
        let json = """
        {
            "key" : {
                "value" : [
                    null,
                    "test",
                    true,
                    false
                ]
            },
            "key2" : [],
            "key3" : {},
            "key4" : 3.1415926,
            "key5" : -50,
            "key6" : -50.0,
            "key7" : 50
        }
        """
        
        let jsonSlices = JSONDecorator.highlight(json, style: previewView.highlightStyle)
        
        print(jsonSlices.map { $0.expand.string })
        
        previewView.dataSource = jsonSlices
    }
}
