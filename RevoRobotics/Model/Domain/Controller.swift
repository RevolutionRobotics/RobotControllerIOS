//
//  Controller.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Controller: Decodable {
    let type: ControllerType
    let drivetrainPriority: Int
    let buttons: ControllerButtonMapping?
    let backgroundPrograms: [ProgramBinding]?
}
