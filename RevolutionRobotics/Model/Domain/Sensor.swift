//
//  Sensor.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Sensor: Port {
    // MARK: - Constants
    private enum Constants {
        static let variableName = "variableName"
        static let type = "type"
    }

    // MARK: - Properties
    var variableName: String
    var type: String

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let variableName = dictionary[Constants.variableName] as? String,
            let type = dictionary[Constants.type] as? String else {
                return nil
        }

        self.variableName = variableName
        self.type = type
    }
}
