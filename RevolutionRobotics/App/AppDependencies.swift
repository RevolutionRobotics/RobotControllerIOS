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
        FirebaseApp.configure()
    }

    private func setupKingfisher() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 1
        ImageCache.default.diskStorage.config.sizeLimit = 0
    }
}
