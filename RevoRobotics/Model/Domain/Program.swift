//
//  Program.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Program: Decodable, Equatable, Hashable {
    let id: String
    let name: LocalizedText
    let blocklyXml: String
    let python: String
    let description: LocalizedText
    let variables: [String]?
    let lastModified: Double

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
