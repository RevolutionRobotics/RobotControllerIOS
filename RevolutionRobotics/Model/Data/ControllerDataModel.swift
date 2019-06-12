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

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class ControllerButtonMappingDataModel: Object {
    // MARK: - Properties
    @objc dynamic var b1: ProgramBindingDataModel?
    @objc dynamic var b2: ProgramBindingDataModel?
    @objc dynamic var b3: ProgramBindingDataModel?
    @objc dynamic var b4: ProgramBindingDataModel?
    @objc dynamic var b5: ProgramBindingDataModel?
    @objc dynamic var b6: ProgramBindingDataModel?

    // MARK: - Initialization
    convenience init(mapping: ControllerButtonMapping) {
        self.init()

        self.b1 = ProgramBindingDataModel(binding: mapping.b1)
        self.b2 = ProgramBindingDataModel(binding: mapping.b2)
        self.b3 = ProgramBindingDataModel(binding: mapping.b3)
        self.b4 = ProgramBindingDataModel(binding: mapping.b4)
        self.b5 = ProgramBindingDataModel(binding: mapping.b5)
        self.b6 = ProgramBindingDataModel(binding: mapping.b6)
    }

    convenience init(b1: ProgramBindingDataModel?,
                     b2: ProgramBindingDataModel?,
                     b3: ProgramBindingDataModel?,
                     b4: ProgramBindingDataModel?,
                     b5: ProgramBindingDataModel?,
                     b6: ProgramBindingDataModel?) {
        self.init()

        self.b1 = b1
        self.b2 = b2
        self.b3 = b3
        self.b4 = b4
        self.b5 = b5
        self.b6 = b6
    }
}

final class ProgramBindingDataModel: Object {
    // MARK: - Properties
    @objc dynamic var programId: String = ""
    @objc dynamic var priority: Int = 0

    // MARK: - Initialization
    convenience init?(binding: ProgramBinding?) {
        guard let binding = binding else { return nil }
        self.init()

        self.programId = binding.programId
        self.priority = binding.priority
    }
}
