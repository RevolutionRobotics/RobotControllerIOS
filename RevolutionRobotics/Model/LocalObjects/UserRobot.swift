//
//  UserRobot.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class UserRobot: Object {
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var buildStatus: Int = 0
    @objc dynamic var actualBuildStep: Int = 0
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var configId: String = ""
    @objc dynamic var customName: String?
    @objc dynamic var customImage: String?
    @objc dynamic var customDescription: String?

    // MARK: - Initialization
    convenience init(id: String,
                     buildStatus: BuildStatus,
                     actualBuildStep: Int,
                     lastModified: Date,
                     configId: String,
                     customName: String?,
                     customImage: String?,
                     customDescription: String?) {
        self.init()
        self.id = id
        self.buildStatus = buildStatus.rawValue
        self.actualBuildStep = actualBuildStep
        self.lastModified = lastModified
        self.configId = configId
        self.customName = customName
        self.customImage = customImage
        self.customDescription = customDescription
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
