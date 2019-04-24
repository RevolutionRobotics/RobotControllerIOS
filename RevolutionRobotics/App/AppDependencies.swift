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

struct AppDependencies {
    func setup() {
        setupFabric()
        setupFirebase()
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
}
