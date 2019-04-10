//
//  UserRobot.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

struct UserRobot {
    // MARK: - Properties
    var id: String
    var buildStatus: BuildStatus
    var actualBuildStep: Int
    var lastModified: Date
    var configId: String
    var customName: String?
    var customImage: URL?
    var customDescription: String?
}
