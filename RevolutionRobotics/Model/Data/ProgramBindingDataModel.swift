//
//  ProgramBindingDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 07. 09..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class ProgramBindingDataModel: Object {
    // MARK: - Properties
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var programId: String = ""
    @objc dynamic var priority: Int = 0

    // MARK: - Initialization
    convenience init?(binding: ProgramBinding?) {
        guard let binding = binding else { return nil }
        self.init()

        self.programId = binding.programId
        self.priority = binding.priority
    }

    convenience init(programId: String, priority: Int) {
        self.init()

        self.programId = programId
        self.priority = priority
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
