//
//  Part.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Part: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let name = "name"
        static let image = "image"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var name: String
    var image: String

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let name = dic[Constants.name] as? String,
            let image = dic[Constants.image] as? String else {
                return nil
        }

        self.name = name
        self.image = image
    }
}
