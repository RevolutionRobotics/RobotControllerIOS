//
//  ProgramBinding.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct ProgramBinding: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let programId = "programId"
        static let priority = "priority"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var programId: String
    var priority: Int

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let programId = dictionary[Constants.programId] as? String,
            let priority = dictionary[Constants.priority] as? Int else {
                return nil
        }

        self.programId = programId
        self.priority = priority
    }
}
