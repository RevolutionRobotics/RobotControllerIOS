//
//  BlocklyListAnalogElementJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class BlocklyListAnalogElementJSONData: JSONRepresentable {
    // MARK: - Constants
    private enum Constants {
        static let multitaskerControllerType = "drive_2sticks"
        static let joystickControllerType = "drive_joystick"
    }

    // MARK: - Properties
    let builtinScriptName: String
    let assignments: JSONRepresentable

    // MARK: - Initialization
    static func joystick(type: String, priority: Int) -> BlocklyListAnalogElementJSONData {
        var controllerType: String = ""
        if type == ControllerType.multiTasker.rawValue {
            controllerType = Constants.multitaskerControllerType
        } else {
            controllerType = Constants.joystickControllerType
        }
        let data = BlocklyListAnalogElementJSONData(
            builtinScriptName: controllerType,
            assignments: AnalogControllerAssignmentJSONData(priority: priority))
        return data
    }

    private init(builtinScriptName: String, assignments: JSONRepresentable) {
        self.builtinScriptName = builtinScriptName
        self.assignments = assignments
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case builtinScriptName
        case assignments
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(builtinScriptName, forKey: CodingKeys.builtinScriptName)
        try container.encode(assignments, forKey: CodingKeys.assignments)
    }
}
