//
//  AppDelegate.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 03. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Firebase
import os

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
        fetchFirebaseData()
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
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let firebaseService = AppContainer.shared.container.unwrappedResolve(FirebaseServiceInterface.self)
            firebaseService.prefetchData(onError: nil)
            DispatchQueue.main.async { [weak self] in
                self?.checkMinVersion(using: firebaseService)
            }
        }
    }

    private func checkMinVersion(using firebaseService: FirebaseServiceInterface) {
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("Failed to get build number")
        }

        let buildNumber = Int(build) ?? 0
        firebaseService.getMinVersion(completion: { [weak self] result in
            switch result {
            case .success(let version):
                if version.ios > buildNumber {
                    self?.showUpdateNeeded()
                    return
                }
            case .failure:
                os_log("Error: Failed to fetch minimum version from Firebase!")
            }
        })
    }

    private func showUpdateNeeded() {
        let updateViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
        guard
            let currentViewController = window?.rootViewController,
            updateViewController.viewIfLoaded?.window == nil
        else { return }

        let modalView = UpdateModalView.instatiate()
        modalView.addTapHandler(callback: { [weak self] in
            let urlString = "itms-apps://itunes.apple.com/app/id1473280499"
            if let appUrl = URL(string: urlString) {
                self?.openAppStore(with: appUrl)
            }
        })

        updateViewController.contentView = modalView
        updateViewController.isCloseHidden = true
        updateViewController.modalTransitionStyle = .crossDissolve
        updateViewController.modalPresentationStyle = .overFullScreen

        currentViewController.present(updateViewController, animated: true, completion: nil)
    }

    private func openAppStore(with url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
