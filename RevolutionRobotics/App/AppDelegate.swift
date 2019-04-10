//
//  AppDelegate.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 03. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    private var navigationController: UINavigationController!
    private let dependencies = AppDependencies()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindowAndRootViewController()
        dependencies.setup()
        FirebaseController.shared.setup()
        return true
    }
}

// MARK: - Setup
extension AppDelegate {
    private func setupWindowAndRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = MenuViewController()
        navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
