//
//  ControllerButtonMappingDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 07. 09..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

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
