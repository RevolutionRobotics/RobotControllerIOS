//
//  LocalConfiguration.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import RealmSwift

final class ConfigurationDataModel: Object {
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var controller: String = ""
    @objc dynamic var mapping: PortMappingDataModel?

    // MARK: - Initialization
    convenience init(id: String,
                     controller: String,
                     mapping: PortMappingDataModel?) {
        self.init()
        self.id = id
        self.controller = controller
        self.mapping = mapping
    }

    convenience init(remoteConfiguration: Configuration) {
        self.init()
        self.id = remoteConfiguration.id
        self.controller = remoteConfiguration.controller
        self.mapping = PortMappingDataModel(remoteMapping: remoteConfiguration.mapping)
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
