//
//  Controller.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Controller: Decodable {
    let id: String
    let name: LocalizedText
    let type: ControllerType
    let configurationId: String
    let joystickPriority: Int
    let description: LocalizedText
    let lastModified: Double
    let mapping: ControllerButtonMapping?
    let backgroundProgramBindings: [ProgramBinding]?
}
