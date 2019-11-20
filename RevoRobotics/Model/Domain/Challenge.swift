//
//  Challenge.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Challenge: FirebaseData, FirebaseOrderable {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let challengeSteps = "challengeSteps"
        static let order = "order"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var id: String
    var name: LocalizedText
    var order: Int
    var challengeSteps: [ChallengeStep]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let order = dictionary[Constants.order] as? Int else {
                return nil
        }

        self.id = id
        self.name = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.name))!
        self.order = order

        let challengeSteps = snapshot.childSnapshot(forPath: Constants.challengeSteps)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> ChallengeStep in
                return ChallengeStep(snapshot: snapshot)!
            }
            .sorted(by: { $0.order < $1.order })
        self.challengeSteps = challengeSteps
    }
}
