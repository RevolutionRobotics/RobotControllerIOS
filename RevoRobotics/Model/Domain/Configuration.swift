//
//  Configuration.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Configuration: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let controller = "controller"
        static let mapping = "mapping"
    }

    // MARK: - Path
    static var firebasePath: String = "configuration"

    // MARK: - Properties
    var id: String
    var controller: String
    var mapping: PortMapping

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let controller = dictionary[Constants.controller] as? String,
            let mapping = PortMapping(snapshot: snapshot.childSnapshot(forPath: Constants.mapping)) else {
                return nil
        }

        self.id = id
        self.controller = controller
        self.mapping = mapping
    }
}
