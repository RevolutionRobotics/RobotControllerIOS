//
//  ControllerButtonMapping.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

// swiftlint:disable identifier_name
struct ControllerButtonMapping {
    // MARK: - Properties
    var b1: ProgramBinding?
    var b2: ProgramBinding?
    var b3: ProgramBinding?
    var b4: ProgramBinding?
    var b5: ProgramBinding?
    var b6: ProgramBinding?

    var programIds: [String?] {
        return [b1?.programId, b2?.programId, b3?.programId, b4?.programId, b5?.programId, b6?.programId]
    }

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        b1 = ProgramBinding(snapshot: snapshot.childSnapshot(forPath: "b1"))
        b2 = ProgramBinding(snapshot: snapshot.childSnapshot(forPath: "b2"))
        b3 = ProgramBinding(snapshot: snapshot.childSnapshot(forPath: "b3"))
        b4 = ProgramBinding(snapshot: snapshot.childSnapshot(forPath: "b4"))
        b5 = ProgramBinding(snapshot: snapshot.childSnapshot(forPath: "b5"))
        b6 = ProgramBinding(snapshot: snapshot.childSnapshot(forPath: "b6"))
    }
}
// swiftlint:enable identifier_name
