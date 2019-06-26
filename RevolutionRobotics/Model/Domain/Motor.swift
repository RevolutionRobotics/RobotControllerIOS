//
//  Motor.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Motor: Port {
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
    var side: Side?
    var rotation: Rotation

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let variableName = dictionary[Constants.variableName] as? String,
            let type = dictionary[Constants.type] as? String,
            let testCodeId = dictionary[Constants.testCodeId] as? Int,
            let tempRotation = dictionary[Constants.rotation] as? String,
            let rotation = Rotation(rawValue: tempRotation) else {
                return nil
        }

        self.variableName = variableName
        self.type = type
        self.testCodeId = testCodeId
        self.rotation = rotation

        if let tempSide = dictionary[Constants.side] as? String, let side = Side(rawValue: tempSide) {
            self.side = side
        }
    }
}
