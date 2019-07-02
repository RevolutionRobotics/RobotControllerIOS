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
        guard let dic = infoDictionary,
            let version = dic["CFBundleShortVersionString"] as? String,
            let build = dic["CFBundleVersion"] as? String else { return "" }
        return version + " " + build
    }
}
