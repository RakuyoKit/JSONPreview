//
//  SearchExampleViewController.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//
#if !os(tvOS)
import UIKit

import JSONPreview

class BaseSearchExampleViewController: BaseJSONPreviewController {
    private lazy var searchBar = UISearchBar()
    
    lazy var keyword: String = "" {
        didSet {
            if keyword.isEmpty {
                previewView.removeSearchStyle { [weak self] _ in
                    self?.previewView.lineNumberTableView.indexPathsForSelectedRows?.forEach {
                        self?.previewView.lineNumberTableView.deselectRow(at: $0, animated: false)
                    }
                }
                
            } else {
                previewView.search(keyword) { [weak self] (lines, _) in
                    lines
                        .lazy
                        .map { IndexPath(row: $0, section: 0) }
                        .forEach {
                            self?.previewView.lineNumberTableView.selectRow(at: $0, animated: false, scrollPosition: .none)
                        }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configSearchBar()
        
        addPreviewViewLayout()
    }
}

// MARK: -

private extension BaseSearchExampleViewController {
    func configSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        addSearchBar()
    }
    
    func addSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        searchBar.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func addPreviewViewLayout() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - UISearchBarDelegate

extension BaseSearchExampleViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        keyword = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        keyword = searchBar.text ?? ""
    }
}
#endif
