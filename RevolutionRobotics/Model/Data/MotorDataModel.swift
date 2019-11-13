//
//  MotorDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class MotorDataModel: Object {
    // MARK: - Constants
    enum Constants {
        static let drive = "drive"
        static let motor = "motor"
    }

    // MARK: - Properties
    @objc dynamic var variableName: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var rotation: String?
    @objc dynamic var side: String?

    // MARK: - Initialization
    convenience init(variableName: String,
                     type: String,
                     rotation: String?,
                     side: String?) {
        self.init()
        self.variableName = variableName
        self.type = type
        self.rotation = rotation
        self.side = side
    }

    convenience init?(remoteMotor: Motor?) {
        guard let remoteMotor = remoteMotor else { return nil }
        self.init()
        self.variableName = remoteMotor.variableName
        self.type = remoteMotor.type
        self.rotation = remoteMotor.rotation.rawValue
        self.side = remoteMotor.side?.rawValue
    }

    convenience init(viewModel: MotorConfigViewModel) {
        self.init()
        self.variableName = viewModel.portName ?? ""
        switch viewModel.state {
        case .drive(let side, let rotation):
            self.type = Constants.drive
            self.side = side.rawValue
            self.rotation = rotation.rawValue
        case .motor(let rotation):
            self.rotation = rotation.rawValue
            self.type = Constants.motor
            self.side = nil
        case .motorWithoutRotation:
            self.type = Constants.motor
            self.side = nil
        default:
            fatalError("Invalid motor configuration view model!")
        }
    }
}
