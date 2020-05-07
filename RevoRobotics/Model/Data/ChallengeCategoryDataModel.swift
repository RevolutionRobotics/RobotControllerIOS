//
//  UserChallengeCategory.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class ChallengeCategoryDataModel: Object {
    // MARK: - Properties
    @objc dynamic var id: String = ""
    dynamic var progress: List<String> = List<String>()

    // MARK: - Initialization
    convenience init(id: String,
                     progress: [String]) {
        self.init()
        self.id = id

        self.progress = List<String>()
        self.progress.append(objectsIn: progress)
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
