//
//  Error+Crashlytics.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Crashlytics

extension Error {
    func report() {
        Crashlytics.sharedInstance().recordError(self)
    }
}
