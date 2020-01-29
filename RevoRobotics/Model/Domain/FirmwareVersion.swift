//
//  FirmwareVersion.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 01. 29..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

struct FirmwareVersion {
    // MARK: - Properties
    let major: Int
    let minor: Int
    let patch: Int

    static let delimiter: Character = "."
    static func intComponent(at index: Int, in components: [String.SubSequence]) -> Int {
        guard components.indices.contains(index) else {
            return 0
        }

        return Int(components[index]) ?? 0
    }
}

// MARK: - Custom initializers
extension FirmwareVersion {
    init?(from version: String) {
        let versionStr = version.lowercased().starts(with: "v")
            ? String(version.dropFirst())
            : version

        let components = versionStr.split(separator: FirmwareVersion.delimiter)
        guard
            let majorComponent = components.first,
            let majorInt = Int(String(majorComponent))
        else {
            return nil
        }

        major = majorInt
        minor = FirmwareVersion.intComponent(at: 1, in: components)
        patch = FirmwareVersion.intComponent(at: 2, in: components)
    }
}

// MARK: - Comparable
extension FirmwareVersion: Comparable {
    static func < (lhs: FirmwareVersion, rhs: FirmwareVersion) -> Bool {
        if lhs.major < rhs.major { return true }
        if lhs.major > rhs.major { return false }

        if lhs.minor < rhs.minor { return true }
        if lhs.minor > rhs.minor { return false }

        if lhs.patch < rhs.patch { return true }
        if lhs.patch > rhs.patch { return false }

        return false
    }

    static func == (lhs: FirmwareVersion, rhs: FirmwareVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}
