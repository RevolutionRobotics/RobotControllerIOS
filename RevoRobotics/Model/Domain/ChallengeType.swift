//
//  ChallengeType.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum ChallengeType: String, Decodable {
    case horizontal
    case vertical
    case zoomable
    case partList
    case button
}
