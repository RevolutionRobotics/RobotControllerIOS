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
        static let robotConfigSegmentedControl = "segmentedcontrol"
        static let shouldShowTutorial = "tutorial"
        static let minVersion = "minVersion"
        static let userPropertiesSet = "userPropertiesSet"
        static let robotRegistered = "robotRegistered"
        static let buildCarbyPromptVisited = "buildCarbyPromptVisited"
    }
}
