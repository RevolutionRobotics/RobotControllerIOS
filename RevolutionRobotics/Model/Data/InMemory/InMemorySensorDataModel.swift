//
//  InMemorySensorDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 22..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

struct InMemorySensorDataModel {
    // MARK: - Properties
    let variableName: String
    let type: String
    let testCodeId: Int

    // MARK: - Initialization
    init?(sensor: SensorDataModel?) {
        guard let sensor = sensor else { return nil }
        self.variableName = sensor.variableName
        self.type = sensor.type
        self.testCodeId = sensor.testCodeId
    }

    init(viewModel: SensorConfigViewModel) {
        self.variableName = viewModel.portName ?? ""
        self.testCodeId = -1
        switch viewModel.type {
        case .bumper:
            self.type = "bumper"
        case .ultrasonic:
            self.type = "ultrasonic"
        default:
            fatalError("Invalid motor configuration view model!")
        }
    }
}
