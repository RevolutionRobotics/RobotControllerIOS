//
//  PortTestCodeService.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import os

//swiftlint:disable convenience_type
final class PortTestCodeService {
    private enum Constants {
        static let pythonExtension = ".py"
        static let bumperTestCodeFileName = "bumperTest"
        static let distanceTestCodeFileName = "distanceTest"
        static let motorTestCodeFileName = "motorTest"
        static let driveTestCodeFileName = "driveTest"
        static let sensorPortPlaceholder = "{SENSOR}"
        static let motorPortPlaceholder = "{MOTOR}"
        static let motorDirectionPlaceholder = "{MOTOR_DIR}"
        static let motorSidePlaceholder = "{MOTOR_SIDE}"
        static let left = "left"
        static let right = "right"
        static let clockwise = "cw"
        static let counterclockwise = "ccw"
    }
}
//swiftlint:enable convenience_type

extension PortTestCodeService: PortTestCodeServiceInterface {
    func bumperTestCode(for portNumber: Int) -> String {
        guard let codePath = Bundle.main.path(forResource: Constants.bumperTestCodeFileName,
                                              ofType: Constants.pythonExtension) else { return "" }
        do {
            let code = try String(contentsOfFile: codePath)
            return code.replacingOccurrences(of: Constants.sensorPortPlaceholder, with: "\(portNumber)")
        } catch {
            os_log("Error: Failed to load bumper test code!")
            return ""
        }
    }

    func distanceTestCode(for portNumber: Int) -> String {
        guard let codePath = Bundle.main.path(forResource: Constants.distanceTestCodeFileName,
                                              ofType: Constants.pythonExtension) else { return "" }
        do {
            let code = try String(contentsOfFile: codePath)
            return code.replacingOccurrences(of: Constants.sensorPortPlaceholder, with: "\(portNumber)")
        } catch {
            os_log("Error: Failed to load distance test code!")
            return ""
        }
    }

    func motorTestCode(for portNumber: Int, direction: Rotation) -> String {
        guard let codePath = Bundle.main.path(forResource: Constants.motorTestCodeFileName,
                                              ofType: Constants.pythonExtension) else { return "" }
        do {
            let code = try String(contentsOfFile: codePath)
            let replacedDirection = direction == .clockwise ? Constants.clockwise : Constants.counterclockwise
            return code
                .replacingOccurrences(of: Constants.motorPortPlaceholder, with: "\(portNumber)")
                .replacingOccurrences(of: Constants.motorDirectionPlaceholder, with: "\(replacedDirection)")
        } catch {
            os_log("Error: Failed to load motor test code!")
            return ""
        }
    }

    func drivatrainTestCode(for portNumber: Int, direction: Rotation, side: Side) -> String {
        guard let codePath = Bundle.main.path(forResource: Constants.driveTestCodeFileName,
                                              ofType: Constants.pythonExtension) else { return "" }
        do {
            let code = try String(contentsOfFile: codePath)
            let replacedDirection = direction == .clockwise ? Constants.clockwise : Constants.counterclockwise
            let replacedSide = side == .left ? Constants.left : Constants.right
            return code
                .replacingOccurrences(of: Constants.motorPortPlaceholder, with: "\(portNumber)")
                .replacingOccurrences(of: Constants.motorDirectionPlaceholder, with: "\(replacedDirection)")
                .replacingOccurrences(of: Constants.motorSidePlaceholder, with: "\(replacedSide)")
        } catch {
            os_log("Error: Failed to load drive test code!")
            return ""
        }
    }
}
