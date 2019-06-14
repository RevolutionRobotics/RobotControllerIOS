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
    private enum Constants {
        static let xmlPostfix = ".xml"
        static let pythonPostfix = ".py"
    }

    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var remoteId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var customDesctipion: String = ""
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var xmlFileName: String = ""
    @objc dynamic var pythonFileName: String = ""
    var variableNames: List<String> = List<String>()

    convenience init(program: Program) {
        self.init()
        self.id = UUID().uuidString
        self.remoteId = program.id
        self.name = program.name
        self.customDesctipion = program.description
        self.lastModified = Date(timeIntervalSince1970: program.lastModified)
        self.xmlFileName = self.id + Constants.xmlPostfix
        self.pythonFileName = self.id + Constants.pythonPostfix

        let list = List<String>()
        program.variables.forEach { variable in
            list.append(variable)
        }
        variableNames = list
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
