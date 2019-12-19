//
//  BuildStatus.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum BuildStatus: Int, Decodable {
    case new = 0
    case initial
    case inProgress
    case completed
    case invalidConfiguration
}
