//
//  AnalogControllerAssignmentItemJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class AnalogControllerAssignmentItemJSONData: JSONRepresentable {
    // MARK: - Properties
    let channels: [Int] = [0, 1]
    let priority: Int

    // MARK: - Initialization
    init(priority: Int) {
        self.priority = priority
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case channels
        case priority
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channels, forKey: CodingKeys.channels)
        try container.encode(priority, forKey: CodingKeys.priority)
    }
}
