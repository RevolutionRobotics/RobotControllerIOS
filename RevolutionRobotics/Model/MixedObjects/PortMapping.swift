//
//  PortMapping.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

// swiftlint:disable identifier_name
struct PortMapping {
    // MARK: - Properties
    var S1: Sensor?
    var S2: Sensor?
    var S3: Sensor?
    var S4: Sensor?

    var M1: Motor?
    var M2: Motor?
    var M3: Motor?
    var M4: Motor?
    var M5: Motor?
    var M6: Motor?

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        S1 = Sensor(snapshot: snapshot.childSnapshot(forPath: "S1"))
        S2 = Sensor(snapshot: snapshot.childSnapshot(forPath: "S2"))
        S3 = Sensor(snapshot: snapshot.childSnapshot(forPath: "S3"))
        S4 = Sensor(snapshot: snapshot.childSnapshot(forPath: "S4"))

        M1 = Motor(snapshot: snapshot.childSnapshot(forPath: "M1"))
        M2 = Motor(snapshot: snapshot.childSnapshot(forPath: "M2"))
        M3 = Motor(snapshot: snapshot.childSnapshot(forPath: "M3"))
        M4 = Motor(snapshot: snapshot.childSnapshot(forPath: "M4"))
        M5 = Motor(snapshot: snapshot.childSnapshot(forPath: "M5"))
        M6 = Motor(snapshot: snapshot.childSnapshot(forPath: "M6"))
    }
}
// swiftlint:enable identifier_name
