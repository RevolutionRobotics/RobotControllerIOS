//
//  Controller.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Controller: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let type = "type"
        static let configurationId = "configurationId"
        static let joystickPriority = "joystickPriority"
        static let description = "description"
        static let lastModified = "lastModified"
        static let mapping = "mapping"
        static let backgroundProgramBindings = "backgroundProgramBindings"
    }

    // MARK: - Path
    static var firebasePath: String = "controller"

    // MARK: - Properties
    var id: String
    var name: LocalizedText
    var type: ControllerType
    var configurationId: String
    var joystickPriority: Int
    var description: LocalizedText
    var lastModified: Double
    var mapping: ControllerButtonMapping
    var backgroundProgramBindings: [ProgramBinding]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let tempType = dictionary[Constants.type] as? String,
            let type = ControllerType(rawValue: tempType),
            let configurationId = dictionary[Constants.configurationId] as? String,
            let joystickPriority = dictionary[Constants.joystickPriority] as? Int,
            let lastModified = dictionary[Constants.lastModified] as? Double,
            let mapping = ControllerButtonMapping(snapshot: snapshot.childSnapshot(forPath: Constants.mapping)) else {
                return nil
        }

        self.id = id
        self.name = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.name))!
        self.type = type
        self.configurationId = configurationId
        self.joystickPriority = joystickPriority
        self.description = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.description))!
        self.lastModified = lastModified
        self.mapping = mapping

        let models = snapshot.childSnapshot(forPath: Constants.backgroundProgramBindings)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> ProgramBinding in
                return ProgramBinding(snapshot: snapshot)!
        }
        self.backgroundProgramBindings = models
    }
}
