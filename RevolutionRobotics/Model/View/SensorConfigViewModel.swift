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
    case ultrasonic

    // MARK: - Initialization
    init(dataModel: SensorDataModel?) {
        guard let dataModel = dataModel else { self = .empty; return }
        switch dataModel.type {
        case SensorDataModel.Constants.bumper:
            self = .bumper
        case SensorDataModel.Constants.ultrasonic:
            self = .ultrasonic
        default:
            self = .empty
        }
    }

    init(dataModel: InMemorySensorDataModel?) {
        guard let dataModel = dataModel else { self = .empty; return }
        switch dataModel.type {
        case SensorDataModel.Constants.bumper:
            self = .bumper
        case SensorDataModel.Constants.ultrasonic:
            self = .ultrasonic
        default:
            self = .empty
        }
    }
}
