//
//  InMemoryPortMappingDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 22..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

final class InMemoryPortMappingDataModel {
    // MARK: - Properties
    var s1: InMemorySensorDataModel?
    var s2: InMemorySensorDataModel?
    var s3: InMemorySensorDataModel?
    var s4: InMemorySensorDataModel?
    var m1: InMemoryMotorDataModel?
    var m2: InMemoryMotorDataModel?
    var m3: InMemoryMotorDataModel?
    var m4: InMemoryMotorDataModel?
    var m5: InMemoryMotorDataModel?
    var m6: InMemoryMotorDataModel?

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
    init() {
        self.s1 = nil
        self.s2 = nil
        self.s3 = nil
        self.s4 = nil
        self.m1 = nil
        self.m2 = nil
        self.m3 = nil
        self.m4 = nil
        self.m5 = nil
        self.m6 = nil
    }

    init?(mapping: PortMappingDataModel?) {
        guard let mapping = mapping else { return nil }
        self.s1 = InMemorySensorDataModel(sensor: mapping.s1)
        self.s2 = InMemorySensorDataModel(sensor: mapping.s2)
        self.s3 = InMemorySensorDataModel(sensor: mapping.s3)
        self.s4 = InMemorySensorDataModel(sensor: mapping.s4)
        self.m1 = InMemoryMotorDataModel(motor: mapping.m1)
        self.m2 = InMemoryMotorDataModel(motor: mapping.m2)
        self.m3 = InMemoryMotorDataModel(motor: mapping.m3)
        self.m4 = InMemoryMotorDataModel(motor: mapping.m4)
        self.m5 = InMemoryMotorDataModel(motor: mapping.m5)
        self.m6 = InMemoryMotorDataModel(motor: mapping.m6)
    }

    func motor(for portNumber: Int) -> InMemoryMotorDataModel? {
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

    func sensor(for portNumber: Int) -> InMemorySensorDataModel? {
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

    func set(motor: InMemoryMotorDataModel?, to portNumber: Int) {
        switch portNumber {
        case ConfigurationView.Constants.m1PortNumber:
            m1 = motor
        case ConfigurationView.Constants.m2PortNumber:
            m2 = motor
        case ConfigurationView.Constants.m3PortNumber:
            m3 = motor
        case ConfigurationView.Constants.m4PortNumber:
            m4 = motor
        case ConfigurationView.Constants.m5PortNumber:
            m5 = motor
        case ConfigurationView.Constants.m6PortNumber:
            m6 = motor
        default:
            break
        }
    }

    func set(sensor: InMemorySensorDataModel?, to portNumber: Int) {
        switch portNumber {
        case ConfigurationView.Constants.s1PortNumber:
            s1 = sensor
        case ConfigurationView.Constants.s2PortNumber:
            s2 = sensor
        case ConfigurationView.Constants.s3PortNumber:
            s3 = sensor
        case ConfigurationView.Constants.s4PortNumber:
            s4 = sensor
        default:
            break
        }
    }
}
