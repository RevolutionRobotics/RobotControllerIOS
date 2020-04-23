//
//  ControllerButtonMapping.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct ControllerButtonMapping: Decodable {
    let b1: ProgramBinding?
    let b2: ProgramBinding?
    let b3: ProgramBinding?
    let b4: ProgramBinding?
    let b5: ProgramBinding?
    let b6: ProgramBinding?

    func programIds() -> [String?] {
        return [b1?.program, b2?.program, b3?.program, b4?.program, b5?.program, b6?.program]
    }
}
