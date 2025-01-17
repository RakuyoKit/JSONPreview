//
//  SceneDelegate.swift
//  JSONPreviewDemo
//
//  Created by Rakuyo on 2024/3/25.
//  Copyright © 2024 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - SceneDelegate

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: UIWindowSceneDelegate

@available(iOS 13.0, tvOS 13.0, *)
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let vc = EntranceTableViewController()
        
        window.rootViewController = UINavigationController(rootViewController: vc)
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    func sceneDidEnterBackground(_: UIScene) { }
    
    func sceneWillEnterForeground(_: UIScene) { }
    
    func sceneDidBecomeActive(_: UIScene) { }
}
