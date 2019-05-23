//
//  InMemoryMotorDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 22..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct InMemoryMotorDataModel {
    // MARK: - Properties
    let variableName: String
    let type: String
    let testCodeId: Int
    let rotation: Rotation?
    let side: Side?

    // MARK: - Initialization
    init?(motor: MotorDataModel?) {
        guard let motor = motor else { return nil }
        self.variableName = motor.variableName
        self.type = motor.type
        self.testCodeId = motor.testCodeId
        if let rotation = motor.rotation {
            self.rotation = Rotation(rawValue: rotation)
        } else {
            self.rotation = nil
        }
        if let side = motor.side {
            self.side = Side(rawValue: side)
        } else {
            self.side = nil
        }
    }

    init(viewModel: MotorConfigViewModel) {
        self.variableName = viewModel.portName ?? ""
        self.testCodeId = -1
        switch viewModel.state {
        case .drivetrain(let side, let rotation):
            self.type = "drivetrain"
            self.side = side
            self.rotation = rotation
        case .motor(let rotation):
            self.rotation = rotation
            self.type = "motor"
            self.side = nil
        default:
            fatalError("Invalid motor configuration view model!")
        }
    }
}
