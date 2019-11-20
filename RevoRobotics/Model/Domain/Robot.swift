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
        static let order = "order"
    }

    // MARK: - Path
    static var firebasePath: String = "robot"

    // MARK: - Properties
    var id: String
    var name: LocalizedText
    var customDescription: LocalizedText
    var coverImageGSURL: String
    var buildTime: String
    var configurationId: String
    var order: Int

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let coverImage = dictionary[Constants.coverImage] as? String,
            let buildTime = dictionary[Constants.buildTime] as? String,
            let configurationId = dictionary[Constants.configurationId] as? String,
            let order = dictionary[Constants.order] as? Int
        else {
            return nil
        }

        self.id = id
        self.name = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.name))!
        self.customDescription = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.description))!
        self.coverImageGSURL = coverImage
        self.buildTime = buildTime
        self.configurationId = configurationId
        self.order = order
    }
}
