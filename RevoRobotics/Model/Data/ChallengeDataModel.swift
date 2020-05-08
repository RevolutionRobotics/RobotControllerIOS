//
//  ChallengeDataModel.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 05. 07..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class ChallengeDataModel: Object {
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var isCompleted: Bool = false
    @objc dynamic var order: Int = 0

    // MARK: - Initialization
    convenience init(id: String, categoryId: String, isCompleted: Bool, order: Int) {
        self.init()
        self.id = id
        self.categoryId = categoryId
        self.isCompleted = isCompleted
        self.order = order
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
