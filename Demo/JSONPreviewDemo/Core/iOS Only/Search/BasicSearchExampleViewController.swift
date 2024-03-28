//
//  BasicSearchExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

import JSONPreview

class BasicSearchExampleViewController: BaseSearchExampleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic Search Example"
        
        previewView.preview(ExampleJSON.mostComprehensive)
    }
}
