//
//  SensorDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class SensorDataModel: Object {
    // MARK: - Constants
    enum Constants {
        static let bumper = "bumper"
        static let ultrasonic = "ultrasonic"
    }

    // MARK: - Properties
    @objc dynamic var variableName: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var testCodeId: Int = 0

    // MARK: - Initialization
    convenience init(variableName: String,
                     type: String,
                     testCodeId: Int) {
        self.init()
        self.variableName = variableName
        self.type = type
        self.testCodeId = testCodeId
    }

    convenience init?(remoteSensor: Sensor?) {
        guard let remoteSensor = remoteSensor else { return nil }
        self.init()
        self.variableName = remoteSensor.variableName
        self.type = remoteSensor.type
        self.testCodeId = remoteSensor.testCodeId
    }

    convenience init(viewModel: SensorConfigViewModel) {
        self.init()
        self.variableName = viewModel.portName ?? ""
        self.testCodeId = -1
        switch viewModel.type {
        case .bumper:
            self.type = Constants.bumper
        case .ultrasonic:
            self.type = Constants.ultrasonic
        default:
            fatalError("Invalid motor configuration view model!")
        }
    }
}
