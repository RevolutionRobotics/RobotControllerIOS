//
//  Bundle+Version.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension Bundle {
    var appVersion: String {
        return self.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    }
}
