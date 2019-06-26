//
//  Robot.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Robot: FirebaseData, FirebaseOrderable {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let coverImage = "coverImage"
        static let buildTime = "buildTime"
        static let configurationId = "configurationId"
        static let defaultProgram = "defaultProgram"
        static let order = "order"
    }

    // MARK: - Path
    static var firebasePath: String = "robot"

    // MARK: - Properties
    var id: String
    var name: String
    var customDescription: String
    var coverImageGSURL: String
    var buildTime: String
    var configurationId: String
    var defaultProgram: String
    var order: Int

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let name = dictionary[Constants.name] as? String,
            let customDescription = dictionary[Constants.description] as? String,
            let coverImage = dictionary[Constants.coverImage] as? String,
            let buildTime = dictionary[Constants.buildTime] as? String,
            let configurationId = dictionary[Constants.configurationId] as? String,
            let order = dictionary[Constants.order] as? Int,
            let defaultProgram = dictionary[Constants.defaultProgram] as? String else {
                return nil
        }

        self.id = id
        self.name = name
        self.customDescription = customDescription
        self.coverImageGSURL = coverImage
        self.buildTime = buildTime
        self.configurationId = configurationId
        self.defaultProgram = defaultProgram
        self.order = order
    }
}
