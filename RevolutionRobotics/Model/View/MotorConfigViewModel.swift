//
//  MotorConfigViewModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct MotorConfigViewModel {
    let portName: String?
    let state: MotorConfigViewModelState
}

enum MotorConfigViewModelState: Equatable {
    case empty
    case driveWithoutSide
    case drive(Side, Rotation)
    case motorWithoutRotation
    case motor(Rotation)

    // MARK: - Initialization
    init(dataModel: MotorDataModel?) {
        guard let dataModel = dataModel else { self = .empty; return }
        switch dataModel.type {
        case MotorDataModel.Constants.motor:
            guard let raw = dataModel.rotation, let rotation = Rotation(rawValue: raw) else { self = .empty; return }
            self = .motor(rotation)
        case MotorDataModel.Constants.drive:
            guard let rotationRaw = dataModel.rotation,
                let sideRaw = dataModel.side,
                let rotation = Rotation(rawValue: rotationRaw),
                let side = Side(rawValue: sideRaw) else { self = .empty; return }
            self = .drive(side, rotation)
        default:
            self = .empty
        }
    }
}
