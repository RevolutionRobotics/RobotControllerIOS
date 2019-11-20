//
//  AppContainer.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Swinject

public final class AppContainer {
    static let shared = AppContainer()
    private init() {
        // no-op
    }

    var container: Container = {
        let container = Container()
        return container
    }()
}
