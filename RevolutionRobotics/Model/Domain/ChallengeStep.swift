//
//  ChallengeStep.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct ChallengeStep: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let title = "title"
        static let description = "description"
        static let image = "image"
        static let parts = "parts"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var id: String
    var title: String
    var description: String
    var image: String
    var parts: [Part]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let id = dic[Constants.id] as? String,
            let title = dic[Constants.title] as? String,
            let description = dic[Constants.description] as? String,
            let image = dic[Constants.image] as? String else {
                return nil
        }

        self.id = id
        self.title = title
        self.description = description
        self.image = image

        let parts = snapshot.childSnapshot(forPath: Constants.parts)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> Part in
                return Part(snapshot: snapshot)!
        }
        self.parts = parts
    }
}
