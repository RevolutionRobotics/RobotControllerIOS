//
//  AppDependencies.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 03. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Fabric
import Firebase
import Kingfisher
import os

struct AppDependencies {
    func setup() {
        setupFirebase()
        setupKingfisher()
    }
}

// MARK: - Setup
extension AppDependencies {
    private func setupFirebase() {
        #if TEST
        initFirebase(with: "GoogleService-Info-test", debug: true)
        #elseif DEV
        initFirebase(with: "GoogleService-Info-dev", debug: true)
        #else
        initFirebase(with: "GoogleService-Info", debug: false)
        #endif
    }

    private func initFirebase(with info: String, debug: Bool) {
        guard
            let path = Bundle.main.path(forResource: info, ofType: ".plist"),
            let options = FirebaseOptions(contentsOfFile: path)
        else {
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
