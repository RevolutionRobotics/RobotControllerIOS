//
//  SensorConfigViewModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct SensorConfigViewModel {
    let portName: String?
    let type: SensorConfigViewModelType
}

enum SensorConfigViewModelType: String {
    case empty
    case bumper
    case distance

    // MARK: - Initialization
    init(dataModel: SensorDataModel?) {
        guard let dataModel = dataModel, let type = SensorConfigViewModelType(rawValue: dataModel.type) else {
            self = .empty
            return
        }

        self = type
    }

    var typeName: String {
        let key: String?

        switch self {
        case .empty:
            key = nil
        case .bumper:
            key = RobotsKeys.Configure.Sensor.bumperButton
        case .distance:
            key = RobotsKeys.Configure.Sensor.distanceButton
        }

        return key?.translate().lowercased() ?? ""
    }
}
