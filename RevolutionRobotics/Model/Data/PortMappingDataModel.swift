//
//  LocalPortMapping.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import RealmSwift

final class PortMappingDataModel: Object {
    // MARK: - Constants
    private enum Constants {
        static let drivetrain = "drivetrain"
        static let motor = "motor"
        static let bumper = "bumper"
        static let ultrasonic = "ultrasonic"
    }

    // MARK: - Properties
    @objc dynamic var s1: SensorDataModel?
    @objc dynamic var s2: SensorDataModel?
    @objc dynamic var s3: SensorDataModel?
    @objc dynamic var s4: SensorDataModel?
    @objc dynamic var m1: MotorDataModel?
    @objc dynamic var m2: MotorDataModel?
    @objc dynamic var m3: MotorDataModel?
    @objc dynamic var m4: MotorDataModel?
    @objc dynamic var m5: MotorDataModel?
    @objc dynamic var m6: MotorDataModel?

    var variableNames: [String] {
        return [s1?.variableName,
                s2?.variableName,
                s3?.variableName,
                s4?.variableName,
                m1?.variableName,
                m2?.variableName,
                m3?.variableName,
                m4?.variableName,
                m5?.variableName,
                m6?.variableName].compactMap({ $0 })
    }

    // MARK: - Initialization
    convenience init(s1: SensorDataModel?,
                     s2: SensorDataModel?,
                     s3: SensorDataModel?,
                     s4: SensorDataModel?,
                     m1: MotorDataModel?,
                     m2: MotorDataModel?,
                     m3: MotorDataModel?,
                     m4: MotorDataModel?,
                     m5: MotorDataModel?,
                     m6: MotorDataModel?) {
        self.init()
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
        self.s4 = s4
        self.m1 = m1
        self.m2 = m2
        self.m3 = m3
        self.m4 = m4
        self.m5 = m5
        self.m6 = m6
    }

    convenience init(remoteMapping: PortMapping) {
        self.init()
        self.s1 = SensorDataModel(remoteSensor: remoteMapping.S1)
        self.s2 = SensorDataModel(remoteSensor: remoteMapping.S2)
        self.s3 = SensorDataModel(remoteSensor: remoteMapping.S3)
        self.s4 = SensorDataModel(remoteSensor: remoteMapping.S4)
        self.m1 = MotorDataModel(remoteMotor: remoteMapping.M1)
        self.m2 = MotorDataModel(remoteMotor: remoteMapping.M2)
        self.m3 = MotorDataModel(remoteMotor: remoteMapping.M3)
        self.m4 = MotorDataModel(remoteMotor: remoteMapping.M4)
        self.m5 = MotorDataModel(remoteMotor: remoteMapping.M5)
        self.m6 = MotorDataModel(remoteMotor: remoteMapping.M6)
    }

    func updateMotor(portNumber: Int, config: MotorConfigViewModel) {
        var dataModel: MotorDataModel? = MotorDataModel()
        dataModel?.variableName = config.portName!
        switch config.state {
        case .drivetrain(let side, let rotation):
            dataModel?.type = Constants.drivetrain
            dataModel?.side = side.rawValue
            dataModel?.rotation = rotation.rawValue
        case .motor(let rotation):
            dataModel?.type = Constants.motor
            dataModel?.rotation = rotation.rawValue
        case .empty, .motorWithoutRotation, .drivetrainWithoutSide:
            dataModel = nil
        }

        set(motor: dataModel, to: portNumber)
    }

    func set(motor: MotorDataModel?, to portNumber: Int) {
        switch portNumber {
        case ConfigurationView.Constants.m1PortNumber:
            self.m1 = motor
        case ConfigurationView.Constants.m2PortNumber:
            self.m2 = motor
        case ConfigurationView.Constants.m3PortNumber:
            self.m3 = motor
        case ConfigurationView.Constants.m4PortNumber:
            self.m4 = motor
        case ConfigurationView.Constants.m5PortNumber:
            self.m5 = motor
        case ConfigurationView.Constants.m6PortNumber:
            self.m6 = motor
        default:
            break
        }
    }

    func updateSensor(portNumber: Int, config: SensorConfigViewModel) {
        var dataModel: SensorDataModel? = SensorDataModel()
        switch config.type {
        case .bumper:
            dataModel?.type = Constants.bumper
        case .ultrasonic:
            dataModel?.type = Constants.ultrasonic
        case .empty:
            dataModel = nil
        }

        set(sensor: dataModel, to: portNumber)
    }

    func set(sensor: SensorDataModel?, to portNumber: Int) {
        switch portNumber {
        case ConfigurationView.Constants.s1PortNumber:
            self.s1 = sensor
        case ConfigurationView.Constants.s2PortNumber:
            self.s2 = sensor
        case ConfigurationView.Constants.s3PortNumber:
            self.s3 = sensor
        case ConfigurationView.Constants.s4PortNumber:
            self.s4 = sensor
        default:
            break
        }
    }

    func motor(for portNumber: Int) -> MotorDataModel? {
        switch portNumber {
        case ConfigurationView.Constants.m1PortNumber:
            return m1
        case ConfigurationView.Constants.m2PortNumber:
            return m2
        case ConfigurationView.Constants.m3PortNumber:
            return m3
        case ConfigurationView.Constants.m4PortNumber:
            return m4
        case ConfigurationView.Constants.m5PortNumber:
            return m5
        case ConfigurationView.Constants.m6PortNumber:
            return m6
        default:
            return nil
        }
    }

    func sensor(for portNumber: Int) -> SensorDataModel? {
        switch portNumber {
        case ConfigurationView.Constants.s1PortNumber:
            return s1
        case ConfigurationView.Constants.s2PortNumber:
            return s2
        case ConfigurationView.Constants.s3PortNumber:
            return s3
        case ConfigurationView.Constants.s4PortNumber:
            return s4
        default:
            return nil
        }
    }
}
