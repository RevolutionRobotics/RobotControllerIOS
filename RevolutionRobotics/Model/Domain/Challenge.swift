//
//  Challenge.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Challenge: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let challengeSteps = "challengeSteps"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var id: String
    var name: String
    var challengeSteps: [ChallengeStep]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let id = dic[Constants.id] as? String,
            let name = dic[Constants.name] as? String else {
                return nil
        }

        self.id = id
        self.name = name

        let challengeSteps = snapshot.childSnapshot(forPath: Constants.challengeSteps)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> ChallengeStep in
                return ChallengeStep(snapshot: snapshot)!
        }
        self.challengeSteps = challengeSteps
    }
}
