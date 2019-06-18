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
    var name: String
    var type: ControllerType
    var configurationId: String
    var joystickPriority: Int
    var description: String
    var lastModified: Double
    var mapping: ControllerButtonMapping
    var backgroundProgramBindings: [ProgramBinding]

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let id = dic[Constants.id] as? String,
            let name = dic[Constants.name] as? String,
            let tempType = dic[Constants.type] as? String,
            let type = ControllerType(rawValue: tempType),
            let configurationId = dic[Constants.configurationId] as? String,
            let joystickPriority = dic[Constants.joystickPriority] as? Int,
            let description = dic[Constants.description] as? String,
            let lastModified = dic[Constants.lastModified] as? Double,
            let mapping = ControllerButtonMapping(snapshot: snapshot.childSnapshot(forPath: Constants.mapping)) else {
                return nil
        }

        self.id = id
        self.name = name
        self.type = type
        self.configurationId = configurationId
        self.joystickPriority = joystickPriority
        self.description = description
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
