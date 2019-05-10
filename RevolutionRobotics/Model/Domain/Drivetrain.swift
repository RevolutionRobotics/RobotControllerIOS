//
//  Drivetrain.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Drivetrain: Port {
    // MARK: - Constants
    private enum Constants {
        static let variableName = "variableName"
        static let type = "type"
        static let testCodeId = "testCodeId"
        static let side = "side"
        static let rotation = "rotation"
    }

    // MARK: - Properties
    var variableName: String
    var type: String
    var testCodeId: Int
    var side: Side
    var rotation: Rotation

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let variableName = dic[Constants.variableName] as? String,
            let type = dic[Constants.type] as? String,
            let testCodeId = dic[Constants.testCodeId] as? Int,
            let tempSide = dic[Constants.side] as? String,
            let side = Side(rawValue: tempSide),
            let tempRotation = dic[Constants.rotation] as? String,
            let rotation = Rotation(rawValue: tempRotation) else {
                return nil
        }

        self.variableName = variableName
        self.type = type
        self.testCodeId = testCodeId
        self.side = side
        self.rotation = rotation
    }
}
