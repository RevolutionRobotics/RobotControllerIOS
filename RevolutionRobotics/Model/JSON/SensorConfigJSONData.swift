//
//  SensorConfigJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

class SensorConfigJSONData: JSONRepresentable {
    // MARK: - Constants
    private enum Constants {
        enum SensorType: Int {
            case ultrasonic = 1
            case bumper = 2
        }
    }

    // MARK: - Properties
    let name: String
    let type: Int

    // MARK: - Initialization
    init?(with dataModel: SensorDataModel?) {
        guard let dataModel = dataModel else { return nil }
        self.name = dataModel.variableName
        self.type = dataModel.type == SensorDataModel.Constants.ultrasonic ?
            Constants.SensorType.ultrasonic.rawValue : Constants.SensorType.bumper.rawValue
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case name
        case type
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(type, forKey: CodingKeys.type)
    }
}
