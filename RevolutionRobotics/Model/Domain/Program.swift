//
//  Program.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Program: FirebaseData, Equatable, Hashable {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let xml = "xml"
        static let python = "python"
        static let description = "description"
        static let variables = "variables"
        static let lastModified = "lastModified"
    }

    // MARK: - Path
    static var firebasePath: String = "program"

    // MARK: - Properties
    var id: String
    var name: String
    var xml: String
    var python: String
    var description: String
    var variables: [String]
    var lastModified: Double

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let name = dictionary[Constants.name] as? String,
            let xml = dictionary[Constants.xml] as? String,
            let python = dictionary[Constants.python] as? String,
            let description = dictionary[Constants.description] as? String,
            let lastModified = dictionary[Constants.lastModified] as? Double else {
                return nil
        }

        self.id = id
        self.name = name
        self.xml = xml
        self.python = python
        self.description = description
        self.lastModified = lastModified

        let variables = snapshot.childSnapshot(forPath: Constants.variables)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> String in
                guard let result = snapshot.value as? String else {
                    return ""
                }
                return result
        }
        self.variables = variables
    }

    var hashValue: Int {
        return id.hashValue
    }
}
