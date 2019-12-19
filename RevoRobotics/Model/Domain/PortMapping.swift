//
//  PortMapping.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

//swiftlint:disable identifier_name
struct PortMapping: Decodable {
    let S1: Sensor?
    let S2: Sensor?
    let S3: Sensor?
    let S4: Sensor?
    let M1: Motor?
    let M2: Motor?
    let M3: Motor?
    let M4: Motor?
    let M5: Motor?
    let M6: Motor?
}
