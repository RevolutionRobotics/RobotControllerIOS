//
//  ProgramDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import RealmSwift

final class ProgramDataModel: Object {
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var remoteId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var customDescription: String = ""
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var robotId: String = ""
    @objc dynamic var xml: String = ""
    @objc dynamic var python: String = ""
    var variableNames: List<String> = List<String>()

    convenience init(program: Program, robotId: String) {
        self.init()
        self.id = UUID().uuidString
        self.remoteId = program.id
        self.name = program.name.text
        self.customDescription = program.description.text
        self.lastModified = Date(timeIntervalSince1970: program.lastModified / 1000.0)
        self.robotId = robotId
        self.xml = program.blocklyXml
        self.python = program.python

        let list = List<String>()
        program.variables?.forEach { list.append($0) }
        variableNames = list
    }

    convenience init(id: String) {
        self.init()
        self.id = id
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
