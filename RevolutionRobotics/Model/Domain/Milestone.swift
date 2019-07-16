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
        static let testCode = "testCode"
        static let testDescription = "testDescription"
        static let testImage = "testImage"
        static let type = "type"
    }

    // MARK: - Properties
    var image: String
    var testCode: String
    var testDescription: LocalizedText
    var testImage: String
    var type: MilestoneType

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let image = dictionary[Constants.image] as? String,
            let testCode = dictionary[Constants.testCode] as? String,
            let testImage = dictionary[Constants.testImage] as? String,
            let milestoneType = MilestoneType(rawValue: (dictionary[Constants.type] as? String)!) else {
                return nil
        }

        self.image = image
        self.testCode = testCode
        self.testDescription = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.testDescription))!
        self.testImage = testImage
        self.type = milestoneType
    }
}

// MARK: - Equatable
extension Milestone: Equatable {
    static func == (lhs: Milestone, rhs: Milestone) -> Bool {
        return lhs.image == rhs.image && lhs.testCode == rhs.testCode && lhs.type == rhs.type
    }
}
