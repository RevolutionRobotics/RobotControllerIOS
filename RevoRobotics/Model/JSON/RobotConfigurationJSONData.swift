//
//  RobotConfigurationJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class RobotConfigurationJSONData: JSONRepresentable {
    // MARK: - Properties
    let motors: [JSONRepresentable]
    let sensors: [JSONRepresentable]

    // MARK: - Initialization
    init(motors: [JSONRepresentable], sensors: [JSONRepresentable]) {
        self.motors = motors
        self.sensors = sensors
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case motors
        case sensors
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(motors, forKey: CodingKeys.motors)
        try container.encode(sensors, forKey: CodingKeys.sensors)
    }
}
