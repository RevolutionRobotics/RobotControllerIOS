//
//  AppDelegate.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 03. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    var currentScreenName: String?

    private var shouldReconnect = false
    private var navigationController: RRNavigationController!
    private let dependencies = AppDependencies()
    private let assemblyRegister = AssemblyRegister()

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        assemblyRegister.registerAssemblies()
        dependencies.setup()
        setupUserDefaults()
        setupWindowAndRootViewController()
        fetchFirebaseData()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        shouldReconnect = true
        let bluetoothService = AppContainer.shared.container.unwrappedResolve(BluetoothServiceInterface.self)
        bluetoothService.disconnect(shouldReconnect: shouldReconnect)

        Analytics.logEvent("leave_app", parameters: [
            "screen": currentScreenName ?? "Unknown"
        ])
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if shouldReconnect {
            shouldReconnect = false
            let bluetoothService = AppContainer.shared.container.unwrappedResolve(BluetoothServiceInterface.self)
            bluetoothService.reconnect()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if shouldReconnect {
            shouldReconnect = false
            let bluetoothService = AppContainer.shared.container.unwrappedResolve(BluetoothServiceInterface.self)
            bluetoothService.reconnect()
        }
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
}

// MARK: - Prefetch data
extension AppDelegate {
    private func fetchFirebaseData() {
        DispatchQueue.global(qos: .userInteractive).async {
            let firebaseService = AppContainer.shared.container.unwrappedResolve(FirebaseServiceInterface.self)
            firebaseService.prefetchData(onError: nil)
        }
    }
}
