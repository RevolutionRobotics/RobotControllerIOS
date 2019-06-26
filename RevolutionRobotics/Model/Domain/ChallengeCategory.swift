//
//  ChallengeCategory.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct ChallengeCategory: FirebaseData, FirebaseOrderable {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let image = "image"
        static let description = "description"
        static let progress = "progress"
        static let challenges = "challenges"
        static let order = "order"
    }

    // MARK: - Path
    static var firebasePath: String = "challengeCategory"

    // MARK: - Properties
    var id: String
    var name: String
    var image: String
    var description: String
    var order: Int
    var challenges: [Challenge]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let name = dictionary[Constants.name] as? String,
            let image = dictionary[Constants.image] as? String,
            let description = dictionary[Constants.description] as? String,
            let order = dictionary[Constants.order] as? Int else {
                return nil
        }

        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.order = order

        let challenges = snapshot.childSnapshot(forPath: Constants.challenges)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> Challenge in
                return Challenge(snapshot: snapshot)!
        }
        self.challenges = challenges
    }
}
