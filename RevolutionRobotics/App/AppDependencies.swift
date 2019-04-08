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

struct AppDependencies {
    func setup() {
        setupFabric()
    }
}

extension AppDependencies {
    private func setupFabric() {
        Fabric.with([Crashlytics.self])
    }
}
