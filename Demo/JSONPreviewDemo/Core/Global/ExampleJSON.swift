//
//  ExampleJSON.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/1/8.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import Foundation

enum ExampleJSON {
    /// Able to demonstrate the most comprehensive support
    static var mostComprehensive: String {
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
    }
    
    static var legalJson: String {
        """
        {
            "nested" : {
                "object" : {
                    "array" : [
                        "string",
                        1234,
                        null,
                        [
                            {
                                "key1" : "value2"
                            },
                            {
                                "key2" : "value2"
                            },
                        ]
                    ],
                    "other empty object" : {},
                    "other object" : {
                        "key": "value"
                    }
                }
            }
        }
        """
    }
}
