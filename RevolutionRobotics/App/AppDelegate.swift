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
    private var navigationController: RRNavigationController!
    private let dependencies = AppDependencies()
    private let assemblyRegister = AssemblyRegister()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        assemblyRegister.registerAssemblies()
        dependencies.setup()
        setupUserDefaults()
        setupWindowAndRootViewController()
        fetchFirebaseData()

        return true
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
}

// MARK: - Setup
extension AppDelegate {
    private func setupWindowAndRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = AppContainer.shared.container.unwrappedResolve(MenuViewController.self)
        navigationController = RRNavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    private func setupUserDefaults() {
        if UserDefaults.standard.value(forKey: UserDefaults.Keys.shouldShowTutorial) == nil {
            UserDefaults.standard.set(true, forKey: UserDefaults.Keys.shouldShowTutorial)
        }
    }

    private func fetchFirebaseData() {
        let firebaseService = AppContainer.shared.container.unwrappedResolve(FirebaseServiceInterface.self)
        firebaseService.prefetchData(onError: nil)
    }
}
