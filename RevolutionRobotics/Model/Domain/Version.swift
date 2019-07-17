//
//  Version.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 07. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Version: FirebaseData {
    // MARK: - Path
    static var firebasePath: String = "minVersion/ios"

    // MARK: - Properties
    var build: Int

    init?(snapshot: DataSnapshot) {
        guard let build = snapshot.value as? Int else {
            return nil
        }

        self.build = build
    }
}
