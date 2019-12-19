//
//  Configuration.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Configuration: Decodable {
    let id: String
    let controller: String
    let mapping: PortMapping
}
