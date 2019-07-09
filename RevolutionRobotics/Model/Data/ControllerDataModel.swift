//
//  ControllerDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 23..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class ControllerDataModel: Object {
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var configurationId: String = ""
    @objc dynamic var joystickPriority: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var controllerDescription: String = ""
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var mapping: ControllerButtonMappingDataModel?
    var backgroundProgramBindings: List<ProgramBindingDataModel> = List<ProgramBindingDataModel>()

    // MARK: - Initialization
    convenience init(controller: Controller) {
        self.init()

        self.id = controller.id
        self.configurationId = controller.configurationId
        self.name = controller.name
        self.type = controller.type.rawValue
        self.joystickPriority = controller.joystickPriority
        self.controllerDescription = controller.description
        self.lastModified = Date(timeIntervalSince1970: controller.lastModified)
        self.mapping = ControllerButtonMappingDataModel(mapping: controller.mapping)
        let list = List<ProgramBindingDataModel>()
        controller.backgroundProgramBindings.forEach { binding in
            guard let dataModel = ProgramBindingDataModel(binding: binding) else { return }
            list.append(dataModel)
        }
        backgroundProgramBindings = list
    }

    convenience init(id: String?, configurationId: String, type: String, mapping: ControllerButtonMappingDataModel) {
        self.init()

        self.id = id ?? UUID().uuidString
        self.configurationId = configurationId
        self.type = type
        self.lastModified = Date()
        self.mapping = mapping
        backgroundProgramBindings = List<ProgramBindingDataModel>()
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
