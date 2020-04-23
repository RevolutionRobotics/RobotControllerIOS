//
//  ConfigurationData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 19..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

struct ConfigurationJSONData: Encodable {
    // MARK: - Constants
    private enum Constants {
        static let emptyMotorCollection = [EmptyJSONObject(),
                                           EmptyJSONObject(),
                                           EmptyJSONObject(),
                                           EmptyJSONObject(),
                                           EmptyJSONObject(),
                                           EmptyJSONObject()]
        static let emptySensorCollection = [EmptyJSONObject(),
                                            EmptyJSONObject(),
                                            EmptyJSONObject(),
                                            EmptyJSONObject(),
                                            EmptyJSONObject(),
                                            EmptyJSONObject()]
    }

    // MARK: - Properties
    private let robotConfig: RobotConfigurationJSONData
    private let blocklyList: [JSONRepresentable]

    // MARK: - Initialization
    //swiftlint:disable function_body_length
    init(configuration: ConfigurationDataModel, controller: ControllerDataModel, programs: [ProgramDataModel]) {
        let motors = configuration.mapping.map { dataModel -> [JSONRepresentable] in
            let m1: JSONRepresentable = MotorConfigJSONData(with: dataModel.m1) ?? EmptyJSONObject()
            let m2: JSONRepresentable = MotorConfigJSONData(with: dataModel.m2) ?? EmptyJSONObject()
            let m3: JSONRepresentable = MotorConfigJSONData(with: dataModel.m3) ?? EmptyJSONObject()
            let m4: JSONRepresentable = MotorConfigJSONData(with: dataModel.m4) ?? EmptyJSONObject()
            let m5: JSONRepresentable = MotorConfigJSONData(with: dataModel.m5) ?? EmptyJSONObject()
            let m6: JSONRepresentable = MotorConfigJSONData(with: dataModel.m6) ?? EmptyJSONObject()

            return [m1, m2, m3, m4, m5, m6]
        }
        let sensors = configuration.mapping.map { dataModel -> [JSONRepresentable] in
            let s1: JSONRepresentable = SensorConfigJSONData(with: dataModel.s1) ?? EmptyJSONObject()
            let s2: JSONRepresentable = SensorConfigJSONData(with: dataModel.s2) ?? EmptyJSONObject()
            let s3: JSONRepresentable = SensorConfigJSONData(with: dataModel.s3) ?? EmptyJSONObject()
            let s4: JSONRepresentable = SensorConfigJSONData(with: dataModel.s4) ?? EmptyJSONObject()

            return [s1, s2, s3, s4]
        }
        self.robotConfig = RobotConfigurationJSONData(motors: motors ?? Constants.emptyMotorCollection,
                                                      sensors: sensors ?? Constants.emptySensorCollection)

        let controllerData = BlocklyListAnalogElementJSONData.joystick(type: controller.type,
                                                                       priority: controller.drivetrainPriority)

        var buttonPrograms: [BlocklyListProgramElementJSONData] = []
        var backgroundPrograms: [BlocklyListProgramElementJSONData] = []

        if let b1mapping = controller.mapping?.b1,
            let b1Program = programs.first(where: { $0.id == b1mapping.programId }) ??
                programs.first(where: { $0.remoteId == b1mapping.programId }) {
            let program = BlocklyListProgramElementJSONData(code: b1Program.python,
                                                            isButton: true,
                                                            priority: b1mapping.priority,
                                                            buttonId: 0)
            buttonPrograms.append(program)
        }
        if let b2mapping = controller.mapping?.b2,
            let b2Program = programs.first(where: { $0.id == b2mapping.programId }) ??
                programs.first(where: { $0.remoteId == b2mapping.programId }) {
            let program = BlocklyListProgramElementJSONData(code: b2Program.python,
                                                            isButton: true,
                                                            priority: b2mapping.priority,
                                                            buttonId: 1)
            buttonPrograms.append(program)
        }
        if let b3mapping = controller.mapping?.b3,
            let b3Program = programs.first(where: { $0.id == b3mapping.programId }) ??
                programs.first(where: { $0.remoteId == b3mapping.programId }) {
            let program = BlocklyListProgramElementJSONData(code: b3Program.python,
                                                            isButton: true,
                                                            priority: b3mapping.priority,
                                                            buttonId: 2)
            buttonPrograms.append(program)
        }
        if let b4mapping = controller.mapping?.b4,
            let b4Program = programs.first(where: { $0.id == b4mapping.programId }) ??
                programs.first(where: { $0.remoteId == b4mapping.programId }) {
            let program = BlocklyListProgramElementJSONData(code: b4Program.python,
                                                            isButton: true,
                                                            priority: b4mapping.priority,
                                                            buttonId: 3)
            buttonPrograms.append(program)
        }
        if let b5mapping = controller.mapping?.b5,
            let b5Program = programs.first(where: { $0.id == b5mapping.programId }) ??
                programs.first(where: { $0.remoteId == b5mapping.programId }) {
            let program = BlocklyListProgramElementJSONData(code: b5Program.python,
                                                            isButton: true,
                                                            priority: b5mapping.priority,
                                                            buttonId: 4)
            buttonPrograms.append(program)
        }
        if let b6mapping = controller.mapping?.b6,
            let b6Program = programs.first(where: { $0.id == b6mapping.programId }) ??
                programs.first(where: { $0.remoteId == b6mapping.programId }) {
            let program = BlocklyListProgramElementJSONData(code: b6Program.python,
                                                            isButton: true,
                                                            priority: b6mapping.priority,
                                                            buttonId: 5)
            buttonPrograms.append(program)
        }
        controller.backgroundProgramBindings.forEach({ binding in
            if let program = programs.first(where: { $0.id == binding.programId }) ??
                programs.first(where: { $0.remoteId == binding.programId }) {
                backgroundPrograms.append(BlocklyListProgramElementJSONData(code: program.python,
                                                                            isButton: false,
                                                                            priority: binding.priority))
            }
        })
        self.blocklyList = [controllerData] + buttonPrograms + backgroundPrograms
    }
    //swiftlint:enable function_body_length
}
