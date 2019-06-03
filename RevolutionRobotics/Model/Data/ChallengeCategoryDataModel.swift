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
    @objc dynamic var progress: Int = 0

    // MARK: - Initialization
    convenience init(id: String,
                     progress: Int) {
        self.init()
        self.id = id
        self.progress = progress
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
