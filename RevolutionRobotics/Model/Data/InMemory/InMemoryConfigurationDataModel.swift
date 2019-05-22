//
//  InMemoryConfigurationDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 22..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct InMemoryConfigurationDataModel {
    let id: String
    let controller: String
    let mapping: InMemoryPortMappingDataModel?

    init(id: String, controller: String, mapping: InMemoryPortMappingDataModel?) {
        self.id = id
        self.controller = controller
        self.mapping = mapping
    }

    init?(configuration: ConfigurationDataModel?) {
        guard let configuration = configuration else { return nil }
        self.id = configuration.id
        self.controller = configuration.controller
        self.mapping = InMemoryPortMappingDataModel(mapping: configuration.mapping)
    }
}
