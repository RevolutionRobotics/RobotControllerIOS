//
//  Locale+Server.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 05. 19..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import Foundation

extension Locale {
    enum Server: String {
        case global, asia
    }

    var userRegion: String? {
        let savedRegion = UserDefaults.standard.string(forKey: UserDefaults.Keys.selectedServer)
        guard (savedRegion ?? "").isEmpty else {
            return savedRegion
        }

        guard let code = regionCode?.uppercased() else {
            return Server.global.rawValue
        }

        return code.contains("CN") || code.contains("CHN")
            ? Server.asia.rawValue
            : Server.global.rawValue
    }
}
