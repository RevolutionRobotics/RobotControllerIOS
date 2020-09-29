//
//  Error+Crashlytics.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Firebase

extension Error {
    func report() {
        Crashlytics.crashlytics().record(error: self)
    }
}
