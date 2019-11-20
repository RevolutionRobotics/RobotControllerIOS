//
//  FirebaseError.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

// MARK: - Error
enum FirebaseError: Error {
    case decodeFailed(String)
    case arrayDecodeFailed(String)
    case imageURLDownloadFailed(String)
    case invalidImageURL
    case invalidRobotId
}
