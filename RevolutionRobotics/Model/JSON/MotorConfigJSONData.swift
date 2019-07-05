//
//  MotorConfigJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

class MotorConfigJSONData: JSONRepresentable {
    // MARK: Constants
    private enum Constants {
        enum MotorType: Int {
            case motor = 1
            case drive = 2
        }

        enum Direction: Int {
            case clockwise = 0
            case counterClockwise = 1
        }

        enum Side: Int {
            case left = 0
            case right = 1
        }
    }

    // MARK: - Properties
    let name: String
    let type: Int
    let direction: Int
    let side: Int

    // MARK: - Initialization
    init?(with dataModel: MotorDataModel?) {
        guard let dataModel = dataModel else { return nil }
        self.name = dataModel.variableName
        self.type = dataModel.type == MotorDataModel.Constants.drive ?
            Constants.MotorType.drive.rawValue : Constants.MotorType.motor.rawValue
        self.direction = dataModel.rotation == Rotation.clockwise.rawValue ?
            Constants.Direction.clockwise.rawValue : Constants.Direction.counterClockwise.rawValue
        self.side = dataModel.side == Side.left.rawValue ? Constants.Side.left.rawValue : Constants.Side.right.rawValue
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case direction
        case side
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(direction, forKey: CodingKeys.direction)
        try container.encode(side, forKey: CodingKeys.side)
    }
}
