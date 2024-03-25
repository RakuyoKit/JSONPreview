//
//  CustomSearchExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//
#if !os(tvOS)
import UIKit

import JSONPreview

class CustomSearchExampleViewController: BaseSearchExampleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cusom Search Example"
        
        if #available(iOS 15.0, *) {
            configBarButtonItem()
        }
        
        previewView.highlightStyle = .mariana
        
        preview()
    }
}

// MARK: -

private extension CustomSearchExampleViewController {
    @available(iOS 15.0, *)
    func configBarButtonItem() {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        button.showsMenuAsPrimaryAction = true
        
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        
        let config = UIImage.SymbolConfiguration(pointSize: 40 * 0.55)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        
        button.menu = .init(
            title: "Styling settings for search results",
            identifier: .root,
            children: [
                UIMenu(
                    identifier: .edit,
                    options: .displayInline,
                    children: [
                        createBoldMenu(),
                        createBackgroundMenu(),
                    ]
                )
            ]
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @available(iOS 15.0, *)
    func createBoldMenu() -> UIMenu {
        let updateBoldedSearchResult: (Bool) -> Void = { [weak self] in
            guard let this = self else { return }
            
            this.previewView.removeSearchStyle()
            this.previewView.highlightStyle.isBoldedSearchResult = $0
            this.keyword = this.keyword
        }
        
        let isBoldedSearchResult = previewView.highlightStyle.isBoldedSearchResult
        
        return .init(
            title: "Bold search results",
            identifier: .font,
            options: .singleSelection,
            children: [
                UIAction(
                    title: "Bold", 
                    state: isBoldedSearchResult ? .on : .off
                ) { _ in
                    updateBoldedSearchResult(true)
                },
                UIAction(
                    title: "Not bold",
                    state: isBoldedSearchResult ? .off : .on
                ) { _ in
                    updateBoldedSearchResult(false)
                },
            ]
        )
    }
    
    @available(iOS 15.0, *)
    func createBackgroundMenu() -> UIMenu {
        let updateSearchResultBackground: (ConvertibleToColor?) -> Void = { [weak self] in
            guard let this = self else { return }
            
            this.previewView.highlightStyle.color.searchHitBackground = $0?.color
            this.keyword = this.keyword
        }
        
        let marianaSearchHitBackground = HighlightStyle.mariana.color.searchHitBackground
        let searchHitBackground = previewView.highlightStyle.color.searchHitBackground
        
        return .init(
            title: "Highlight search results",
            identifier: .textStyle,
            options: .singleSelection,
            children: [
                UIAction(
                    title: "System Default",
                    state: searchHitBackground == marianaSearchHitBackground ? .on : .off
                ) { _ in
                    updateSearchResultBackground(marianaSearchHitBackground)
                },
                UIAction(
                    title: "Not highlighting",
                    state: searchHitBackground == nil ? .on : .off
                ) { _ in
                    updateSearchResultBackground(nil)
                },
                UIAction(
                    title: "Custom",
                    state: {
                        let result = searchHitBackground != nil && searchHitBackground != marianaSearchHitBackground
                        return result ? .on : .off
                    }()
                ) { [weak self] _ in
                    self?.showCustomColorInputAlert()
                },
            ]
        )
    }
    
    func showCustomColorInputAlert() {
        let alert = UIAlertController(title: "Please enter", message: "Like \"#FDA700\"", preferredStyle: .alert)
        
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard
                let this = self,
                let colorString = alert.textFields?.last?.text
            else {
                return
            }
            
            this.previewView.highlightStyle.color.searchHitBackground = colorString.color
            this.previewView.search(this.keyword)
        })
        
        present(alert, animated: true)
    }
    
    func preview() {
        let json = ExampleJSON.mostComprehensive
        previewView.preview(json)
    }
}
#endif
