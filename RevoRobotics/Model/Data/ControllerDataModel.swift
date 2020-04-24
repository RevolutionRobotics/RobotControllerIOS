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
    @objc dynamic var drivetrainPriority: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var mapping: ControllerButtonMappingDataModel?
    var backgroundProgramBindings: List<ProgramBindingDataModel> = List<ProgramBindingDataModel>()

    // MARK: - Initialization
    convenience init(controller: Controller, localConfigurationId: String) {
        self.init()

        self.id = UUID().uuidString
        self.configurationId = localConfigurationId
        self.type = controller.type.rawValue
        self.drivetrainPriority = controller.drivetrainPriority

        if let controllerMapping = controller.buttons {
            self.mapping = ControllerButtonMappingDataModel(mapping: controllerMapping)
        }

        let list = List<ProgramBindingDataModel>()
        controller.backgroundPrograms?.forEach { binding in
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
        self.mapping = mapping
        backgroundProgramBindings = List<ProgramBindingDataModel>()
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
