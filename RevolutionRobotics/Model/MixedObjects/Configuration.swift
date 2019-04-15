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

    // MARK: - Properties
    var id: Int
    var controller: String
    var mapping: PortMapping

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let id = dic[Constants.id] as? Int,
            let controller = dic[Constants.controller] as? String,
            let mapping = PortMapping(snapshot: snapshot.childSnapshot(forPath: Constants.mapping)) else {
                return nil
        }

        self.id = id
        self.controller = controller
        self.mapping = mapping
    }
}
