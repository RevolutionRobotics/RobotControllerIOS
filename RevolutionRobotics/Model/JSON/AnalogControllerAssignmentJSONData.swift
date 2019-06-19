//
//  AnalogControllerAssignmentJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class AnalogControllerAssignmentJSONData: JSONRepresentable {
    // MARK: - Properties
    let analog: [AnalogControllerAssignmentItemJSONData]

    // MARK: - Initialization
    init(priority: Int) {
        self.analog = [AnalogControllerAssignmentItemJSONData(priority: priority)]
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case analog
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(analog, forKey: CodingKeys.analog)
    }
}
