//
//  BuildStep.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct BuildStep: Decodable, Equatable {
    let robotId: String
    let image: String
    let partImage: String?
    let partImage2: String?
    let stepNumber: Int
    let milestone: Milestone?
}
