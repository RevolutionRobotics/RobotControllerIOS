//
//  Sensor.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Sensor: Port, Decodable {
    var variableName: String
    var type: String
}
