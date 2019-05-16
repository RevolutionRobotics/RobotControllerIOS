//
//  ChallengeCategory.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct ChallengeCategory: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let image = "image"
        static let description = "description"
        static let progress = "progress"
        static let challenges = "challenges"
    }

    // MARK: - Path
    static var firebasePath: String = "challengeCategory"

    // MARK: - Properties
    var id: String
    var name: String
    var image: String
    var description: String
    var progress: Int
    var challenges: [Challenge]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let id = dic[Constants.id] as? String,
            let name = dic[Constants.name] as? String,
            let image = dic[Constants.image] as? String,
            let description = dic[Constants.description] as? String,
            let progress = dic[Constants.progress] as? Int else {
                return nil
        }

        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.progress = progress

        let challenges = snapshot.childSnapshot(forPath: Constants.challenges)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> Challenge in
                return Challenge(snapshot: snapshot)!
        }
        self.challenges = challenges
    }
}
