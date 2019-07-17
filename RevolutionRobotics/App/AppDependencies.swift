//
//  AppDependencies.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 03. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics
import Firebase
import Kingfisher
import os

struct AppDependencies {
    func setup() {
        setupFabric()
        setupFirebase()
        setupKingfisher()
    }
}

// MARK: - Setup
extension AppDependencies {
    private func setupFabric() {
        Fabric.with([Crashlytics.self])
    }

    private func setupFirebase() {
        let path: String
        #if PROD
        path = Bundle.main.path(forResource: "GoogleService-Info", ofType: ".plist")!
        #else
        path = Bundle.main.path(forResource: "GoogleService-Info-dev", ofType: ".plist")!
        #endif
        guard let options = FirebaseOptions(contentsOfFile: path) else {
            os_log("Failed to load Firebase options!")
            return
        }
        FirebaseApp.configure(options: options)
    }

    private func setupKingfisher() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 1
        ImageCache.default.diskStorage.config.sizeLimit = 0
    }
}
