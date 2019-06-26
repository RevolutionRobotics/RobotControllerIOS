//
//  Part.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Part: FirebaseData, FirebaseOrderable {
    // MARK: - Constants
    private enum Constants {
        static let name = "name"
        static let image = "image"
        static let order = "order"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var name: String
    var image: String
    var order: Int

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let name = dictionary[Constants.name] as? String,
            let order = dictionary[Constants.order] as? Int,
            let image = dictionary[Constants.image] as? String else {
                return nil
        }

        self.name = name
        self.image = image
        self.order = order
    }
}
