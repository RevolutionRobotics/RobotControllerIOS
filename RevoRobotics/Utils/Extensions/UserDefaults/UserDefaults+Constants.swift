//
//  UserDefaults+Constants.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let jsonCache = "jsonCache"
        static let robotConfigSegmentedControl = "segmentedcontrol"
        static let shouldShowTutorial = "tutorial"
        static let minVersion = "minVersion"
        static let robotRegistered = "robotRegistered"
        static let buildRevvyPromptVisited = "buildRevvyPromptVisited"
        static let revvyBuilt = "revvyBuilt"
        static let mostRecentProgram = "mostRecentProgram"
        static let selectedServer = "selectedServer"
    }
}
