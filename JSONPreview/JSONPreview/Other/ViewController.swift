//
//  ViewController.swift
//  JSONPreview
//
//  Created by Rakuyo on 2020/9/9.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        print(JSONDecorator.highlight(json).map { $0.expand.string })
    }
}
