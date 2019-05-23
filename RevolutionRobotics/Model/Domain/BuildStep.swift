//
//  BuildStep.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct BuildStep: FirebaseData, Equatable {
    // MARK: - Constants
    private enum Constants {
        static let robotId = "robotId"
        static let image = "image"
        static let partImage = "partImage"
        static let stepNumber = "stepNumber"
        static let milestone = "milestone"
    }

    // MARK: - Path
    static var firebasePath: String = "buildStep"

    // MARK: - Properties
    var robotId: String
    var image: String
    var partImage: String
    var stepNumber: Int
    var milestone: Milestone?

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let robotId = dic[Constants.robotId] as? Int,
            let image = dic[Constants.image] as? String,
            let partImage = dic[Constants.partImage] as? String,
            let stepNumber = dic[Constants.stepNumber] as? Int else {
                return nil
        }

        self.robotId = "\(robotId)"
        self.image = image
        self.partImage = partImage
        self.stepNumber = stepNumber
        self.milestone = Milestone(snapshot: snapshot.childSnapshot(forPath: Constants.milestone))
    }
}
