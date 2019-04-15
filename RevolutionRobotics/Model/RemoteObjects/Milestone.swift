//
//  Milestone.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Milestone {
    // MARK: - Constants
    private enum Constants {
        static let image = "image"
        static let testCodeId = "testCodeId"
        static let type = "type"
    }

    // MARK: - Properties
    var image: String
    var testCodeId: String
    var type: MilestoneType

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let image = dic[Constants.image] as? String,
            let testCodeId = dic[Constants.testCodeId] as? String,
            let type = dic[Constants.type] as? String,
            let milestoneType = MilestoneType(rawValue: type) else {
                return nil
        }

        self.image = image
        self.testCodeId = testCodeId
        self.type = milestoneType
    }
}
