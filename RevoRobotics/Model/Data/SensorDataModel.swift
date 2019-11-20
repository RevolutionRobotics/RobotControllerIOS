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
        static let distance = "distance"
    }

    // MARK: - Properties
    @objc dynamic var variableName: String = ""
    @objc dynamic var type: String = ""

    // MARK: - Initialization
    convenience init(variableName: String,
                     type: String) {
        self.init()
        self.variableName = variableName
        self.type = type
    }

    convenience init?(remoteSensor: Sensor?) {
        guard let remoteSensor = remoteSensor else { return nil }
        self.init()
        self.variableName = remoteSensor.variableName
        self.type = remoteSensor.type
    }

    convenience init(viewModel: SensorConfigViewModel) {
        self.init()
        self.variableName = viewModel.portName ?? ""
        self.type = viewModel.type.rawValue
    }
}
