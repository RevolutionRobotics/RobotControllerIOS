//
//  Robot.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Robot: Decodable, FirebaseOrderable {
    let id: String
    let name: LocalizedText
    let description: LocalizedText
    let coverImage: String
    let buildTime: String
    let complexity: String
    let compatibility: [String]
    let portMapping: PortMapping
    let controller: Controller
    let buildSteps: [BuildStep]
    let buildStepsArchive: String
    let programs: [Program]
    var order: Int
}
